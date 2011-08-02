require 'new_relic/agent/instrumentation/metric_frame/pop'

# A struct holding the information required to measure a controller
# action.  This is put on the thread local.  Handles the issue of
# re-entrancy, or nested action calls.
#
# This class is not part of the public API.  Avoid making calls on it directly.
#
module NewRelic
  module Agent
    module Instrumentation
      class MetricFrame
        # helper module refactored out of the `pop` method
        include Pop

        attr_accessor :start       # A Time instance for the start time, never nil
        attr_accessor :apdex_start # A Time instance used for calculating the apdex score, which
        # might end up being @start, or it might be further upstream if
        # we can find a request header for the queue entry time
        attr_accessor :exception,
        :filtered_params, :force_flag,
        :jruby_cpu_start, :process_cpu_start, :database_metric_name

        # Give the current metric frame a request context.  Use this to
        # get the URI and referer.  The request is interpreted loosely
        # as a Rack::Request or an ActionController::AbstractRequest.
        attr_accessor :request


        @@check_server_connection = false
        def self.check_server_connection=(value)
          @@check_server_connection = value
        end
        # Return the currently active metric frame, or nil.  Call with +true+
        # to create a new metric frame if one is not already on the thread.
        def self.current(create_if_empty=nil)
          f = Thread.current[:newrelic_metric_frame]
          return f if f || !create_if_empty

          # Reconnect to the server if necessary.  This is only done
          # for old versions of passenger that don't implement an explicit after_fork
          # event.
          agent.after_fork(:keep_retrying => false) if @@check_server_connection

          Thread.current[:newrelic_metric_frame] = new
        end

        # This is the name of the model currently assigned to database
        # measurements, overriding the default.
        def self.database_metric_name
          current && current.database_metric_name
        end

        def self.referer
          current && current.referer
        end

        def self.agent
          NewRelic::Agent.instance
        end

        @@java_classes_loaded = false

        if defined? JRuby
          begin
            require 'java'
            include_class 'java.lang.management.ManagementFactory'
            include_class 'com.sun.management.OperatingSystemMXBean'
            @@java_classes_loaded = true
          rescue Exception => e
          end
        end

        attr_reader :depth

        def initialize
          Thread.current[:newrelic_start_time] = @start = Time.now
          @path_stack = [] # stack of [controller, path] elements
          @jruby_cpu_start = jruby_cpu_time
          @process_cpu_start = process_cpu
        end

        def agent
          NewRelic::Agent.instance
        end

        def transaction_sampler
          agent.transaction_sampler
        end

        private :agent
        private :transaction_sampler


        # Indicate that we are entering a measured controller action or task.
        # Make sure you unwind every push with a pop call.
        def push(m)
          transaction_sampler.notice_first_scope_push(start)
          @path_stack.push NewRelic::MetricParser::MetricParser.for_metric_named(m)
        end

        # Indicate that you don't want to keep the currently saved transaction
        # information
        def self.abort_transaction!
          current.abort_transaction! if current
        end

        # For the current web transaction, return the path of the URI minus the host part and query string, or nil.
        def uri
          @uri ||= self.class.uri_from_request(@request) unless @request.nil?
        end

        # For the current web transaction, return the full referer, minus the host string, or nil.
        def referer
          @referer ||= self.class.referer_from_request(@request)
        end

        # Call this to ensure that the current transaction is not saved
        def abort_transaction!
          transaction_sampler.ignore_transaction
        end
        # This needs to be called after entering the call to trace the
        # controller action, otherwise the controller action blames
        # itself.  It gets reset in the normal #pop call.
        def start_transaction
          agent.stats_engine.start_transaction metric_name
          # Only push the transaction context info once, on entry:
          if @path_stack.size == 1
            transaction_sampler.notice_transaction(metric_name, uri, filtered_params)
          end
        end

        def current_metric
          @path_stack.last
        end

        # Return the path, the part of the metric after the category
        def path
          @path_stack.last.last
        end

        # Unwind one stack level.  It knows if it's back at the outermost caller and
        # does the appropriate wrapup of the context.
        def pop
          metric = @path_stack.pop
          log_underflow if metric.nil?
          if @path_stack.empty?
            handle_empty_path_stack(metric)
          else
            set_new_scope!(current_stack_metric)
          end
        end

        # If we have an active metric frame, notice the error and increment the error metric.
        # Options:
        # * <tt>:request</tt> => Request object to get the uri and referer
        # * <tt>:uri</tt> => The request path, minus any request params or query string.
        # * <tt>:referer</tt> => The URI of the referer
        # * <tt>:metric</tt> => The metric name associated with the transaction
        # * <tt>:request_params</tt> => Request parameters, already filtered if necessary
        # * <tt>:custom_params</tt> => Custom parameters
        # Anything left over is treated as custom params

        def self.notice_error(e, options={})
          request = options.delete(:request)
          if request
            options[:referer] = referer_from_request(request)
            options[:uri] = uri_from_request(request)
          end
          if current
            current.notice_error(e, options)
          else
            agent.error_collector.notice_error(e, options)
          end
        end

        # Do not call this.  Invoke the class method instead.
        def notice_error(e, options={}) # :nodoc:
          params = custom_parameters
          options[:referer] = referer if referer
          options[:request_params] = filtered_params if filtered_params
          options[:uri] = uri if uri
          options[:metric] = metric_name
          options.merge!(custom_parameters)
          if exception != e
            result = agent.error_collector.notice_error(e, options)
            self.exception = result if result
          end
        end

        # Add context parameters to the metric frame.  This information will be passed in to errors
        # and transaction traces.  Keys and Values should be strings, numbers or date/times.
        def self.add_custom_parameters(p)
          current.add_custom_parameters(p) if current
        end

        def self.custom_parameters
          (current && current.custom_parameters) ? current.custom_parameters : {}
        end

        def record_apdex()
          return unless recording_web_transaction? && NewRelic::Agent.is_execution_traced?
          t = Time.now
          self.class.record_apdex(current_metric, t - start, t - apdex_start, !exception.nil?)
        end

        def metric_name
          return nil if @path_stack.empty?
          current_metric.name
        end

        # Return the array of metrics to record for the current metric frame.
        def recorded_metrics
          metrics = [ metric_name ]
          metrics += current_metric.summary_metrics if @path_stack.size == 1
          metrics
        end

        # Yield to a block that is run with a database metric name context.  This means
        # the Database instrumentation will use this for the metric name if it does not
        # otherwise know about a model.  This is re-entrant.
        #
        # * <tt>model</tt> is the DB model class
        # * <tt>method</tt> is the name of the finder method or other method to identify the operation with.
        #
        def with_database_metric_name(model, method)
          previous = @database_metric_name
          model_name = case model
                       when Class
                         model.name
                       when String
                         model
                       else
                         model.to_s
                       end
          @database_metric_name = "ActiveRecord/#{model_name}/#{method}"
          yield
        ensure
          @database_metric_name=previous
        end

        def custom_parameters
          @custom_parameters ||= {}
        end

        def add_custom_parameters(p)
          custom_parameters.merge!(p)
        end

        def self.recording_web_transaction?
          c = Thread.current[:newrelic_metric_frame]
          if c
            c.recording_web_transaction?
          end
        end

        def recording_web_transaction?
          current_metric && current_metric.is_web_transaction?
        end

        def is_web_transaction?(metric)
          0 == metric.index("Controller")
        end

        # Make a safe attempt to get the referer from a request object, generally successful when
        # it's a Rack request.
        def self.referer_from_request(request)
          if request && request.respond_to?(:referer)
            request.referer.to_s.split('?').first
          end
        end

        # Make a safe attempt to get the URI, without the host and query string.
        def self.uri_from_request(request)
          approximate_uri = case
                            when request.respond_to?(:fullpath) then request.fullpath
                            when request.respond_to?(:path) then request.path
                            when request.respond_to?(:request_uri) then request.request_uri
                            when request.respond_to?(:uri) then request.uri
                            when request.respond_to?(:url) then request.url
                            end
          return approximate_uri[%r{^(https?://.*?)?(/[^?]*)}, 2] || '/' if approximate_uri # '
        end

        def self.record_apdex(current_metric, action_duration, total_duration, is_error)
          summary_stat = agent.stats_engine.get_custom_stats("Apdex", NewRelic::ApdexStats)
          controller_stat = agent.stats_engine.get_custom_stats(current_metric.apdex_metric_path, NewRelic::ApdexStats)
          update_apdex(summary_stat, total_duration, is_error)
          update_apdex(controller_stat, action_duration, is_error)
        end

        # Record an apdex value for the given stat.  when `failed`
        # the apdex should be recorded as a failure regardless of duration.
        def self.update_apdex(stat, duration, failed)
          duration = duration.to_f
          apdex_t = NewRelic::Control.instance.apdex_t
          case
          when failed
            stat.record_apdex_f
          when duration <= apdex_t
            stat.record_apdex_s
          when duration <= 4 * apdex_t
            stat.record_apdex_t
          else
            stat.record_apdex_f
          end
        end

        private

        def process_cpu
          return nil if defined? JRuby
          p = Process.times
          p.stime + p.utime
        end

        def jruby_cpu_time # :nodoc:
          return nil unless @@java_classes_loaded
          threadMBean = ManagementFactory.getThreadMXBean()
          java_utime = threadMBean.getCurrentThreadUserTime()  # ns
          -1 == java_utime ? 0.0 : java_utime/1e9
        end
      end
    end
  end
end
