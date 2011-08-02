module NewRelic
  module Agent
    # This class collects errors from the parent application, storing
    # them until they are harvested and transmitted to the server
    class ErrorCollector
      include NewRelic::CollectionHelper

      # Defined the methods that need to be stubbed out when the
      # agent is disabled
      module Shim #:nodoc:
        def notice_error(*args); end
      end
      
      # Maximum possible length of the queue - defaults to 20, may be
      # made configurable in the future. This is a tradeoff between
      # memory and data retention
      MAX_ERROR_QUEUE_LENGTH = 20 unless defined? MAX_ERROR_QUEUE_LENGTH

      attr_accessor :enabled
      attr_reader :config_enabled
      
      # Returns a new error collector
      def initialize
        @errors = []
        # lookup of exception class names to ignore.  Hash for fast access
        @ignore = {}
        @ignore_filter = nil

        config = NewRelic::Control.instance.fetch('error_collector', {})

        @enabled = @config_enabled = config.fetch('enabled', true)
        @capture_source = config.fetch('capture_source', true)

        ignore_errors = config.fetch('ignore_errors', "")
        ignore_errors = ignore_errors.split(",") if ignore_errors.is_a? String
        ignore_errors.each { |error| error.strip! }
        ignore(ignore_errors)
        @lock = Mutex.new
      end
      
      # Helper method to get the NewRelic::Control.instance
      def control
        NewRelic::Control.instance
      end
      
      # Returns the error filter proc that is used to check if an
      # error should be reported. When given a block, resets the
      # filter to the provided block
      def ignore_error_filter(&block)
        if block
          @ignore_filter = block
        else
          @ignore_filter
        end
      end

      # errors is an array of Exception Class Names
      #
      def ignore(errors)
        errors.each { |error| @ignore[error] = true; log.debug("Ignoring errors of type '#{error}'") }
      end
      
      # This module was extracted from the notice_error method - it is
      # internally tested and can be refactored without major issues.
      module NoticeError
        # Whether the error collector is disabled or not
        def disabled?
          !@enabled
        end
        
        # Checks the provided error against the error filter, if there
        # is an error filter
        def filtered_by_error_filter?(error)
          return unless @ignore_filter
          !@ignore_filter.call(error)
        end
        
        # Checks the array of error names and the error filter against
        # the provided error
        def filtered_error?(error)
          @ignore[error.class.name] || filtered_by_error_filter?(error)
        end
        
        # an error is ignored if it is nil or if it is filtered
        def error_is_ignored?(error)
          error && filtered_error?(error)
        end
        
        # Increments a statistic that tracks total error rate
        def increment_error_count!
          NewRelic::Agent.get_stats("Errors/all").increment_count
        end
        
        # whether we should return early from the notice_error process
        # - based on whether the error is ignored or the error
        # collector is disabled
        def should_exit_notice_error?(exception)
          if @enabled
            if !error_is_ignored?(exception)
              increment_error_count!
              return exception.nil? # exit early if the exception is nil
            end
          end
          # disabled or an ignored error, per above
          true
        end
        
        # acts just like Hash#fetch, but deletes the key from the hash
        def fetch_from_options(options, key, default=nil)
          options.delete(key) || default
        end
        
        # returns some basic option defaults pulled from the provided
        # options hash
        def uri_ref_and_root(options)
          {
            :request_uri => fetch_from_options(options, :uri, ''),
            :request_referer => fetch_from_options(options, :referer, ''),
            :rails_root => control.root
          }
        end
        
        # If anything else is left over, we treat it like a custom param
        def custom_params_from_opts(options)
          # If anything else is left over, treat it like a custom param:
          fetch_from_options(options, :custom_params, {}).merge(options)
        end
        
        # takes the request parameters out of the options hash, and
        # returns them if we are capturing parameters, otherwise
        # returns nil
        def request_params_from_opts(options)
          value = options.delete(:request_params)
          if control.capture_params
            value
          else
            nil
          end
        end
        
        # normalizes the request and custom parameters before attaching
        # them to the error. See NewRelic::CollectionHelper#normalize_params
        def normalized_request_and_custom_params(options)
          {
            :request_params => normalize_params(request_params_from_opts(options)),
            :custom_params  => normalize_params(custom_params_from_opts(options))
          }
        end
        
        # Merges together many of the options into something that can
        # actually be attached to the error
        def error_params_from_options(options)
          uri_ref_and_root(options).merge(normalized_request_and_custom_params(options))
        end
        
        # calls a method on an object, if it responds to it - used for
        # detection and soft fail-safe. Returns nil if the method does
        # not exist
        def sense_method(object, method)
          object.send(method) if object.respond_to?(method)
        end
        
        # extracts source from the exception, if the exception supports
        # that method
        def extract_source(exception)
          sense_method(exception, 'source_extract') if @capture_source
        end
        
        # extracts a stack trace from the exception for debugging purposes
        def extract_stack_trace(exception)
          actual_exception = sense_method(exception, 'original_exception') || exception
          sense_method(actual_exception, 'backtrace') || '<no stack trace>'
        end
        
        # extracts a bunch of information from the exception to include
        # in the noticed error - some may or may not be available, but
        # we try to include all of it
        def exception_info(exception)
          {
            :file_name => sense_method(exception, 'file_name'),
            :line_number => sense_method(exception, 'line_number'),
            :source => extract_source(exception),
            :stack_trace => extract_stack_trace(exception)
          }
        end
        
        # checks the size of the error queue to make sure we are under
        # the maximum limit, and logs a warning if we are over the limit.
        def over_queue_limit?(message)
          over_limit = (@errors.length >= MAX_ERROR_QUEUE_LENGTH)
          log.warn("The error reporting queue has reached #{MAX_ERROR_QUEUE_LENGTH}. The error detail for this and subsequent errors will not be transmitted to New Relic until the queued errors have been sent: #{message}") if over_limit
          over_limit
        end

        
        # Synchronizes adding an error to the error queue, and checks if
        # the error queue is too long - if so, we drop the error on the
        # floor after logging a warning.
        def add_to_error_queue(noticed_error)
          @lock.synchronize do
            @errors << noticed_error unless over_queue_limit?(noticed_error.message)
          end
        end
      end

      include NoticeError

      # Notice the error with the given available options:
      #
      # * <tt>:uri</tt> => The request path, minus any request params or query string.
      # * <tt>:referer</tt> => The URI of the referer
      # * <tt>:metric</tt> => The metric name associated with the transaction
      # * <tt>:request_params</tt> => Request parameters, already filtered if necessary
      # * <tt>:custom_params</tt> => Custom parameters
      #
      # If anything is left over, it's added to custom params
      # If exception is nil, the error count is bumped and no traced error is recorded
      def notice_error(exception, options={})
        return if should_exit_notice_error?(exception)
        action_path     = fetch_from_options(options, :metric, (NewRelic::Agent.instance.stats_engine.scope_name || ''))
        exception_options = error_params_from_options(options).merge(exception_info(exception))
        add_to_error_queue(NewRelic::NoticedError.new(action_path, exception_options, exception))
        exception
      rescue Exception => e
        log.error("Error capturing an error, yodawg. #{e}")
      end

      # Get the errors currently queued up.  Unsent errors are left
      # over from a previous unsuccessful attempt to send them to the server.
      def harvest_errors(unsent_errors)
        @lock.synchronize do
          errors = @errors
          @errors = []

          if unsent_errors && !unsent_errors.empty?
            errors = unsent_errors + errors
          end

          errors
        end
      end

      private
      def log
        NewRelic::Agent.logger
      end
    end
  end
end
