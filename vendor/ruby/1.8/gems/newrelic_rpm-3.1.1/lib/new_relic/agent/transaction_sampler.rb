require 'new_relic/agent'
require 'new_relic/control'
require 'new_relic/agent/transaction_sample_builder'
module NewRelic
  module Agent
    
    # This class contains the logic of sampling a transaction -
    # creation and modification of transaction samples
    class TransactionSampler

      # Module defining methods stubbed out when the agent is disabled
      module Shim #:nodoc:
        def notice_first_scope_push(*args); end
        def notice_push_scope(*args); end
        def notice_pop_scope(*args); end
        def notice_scope_empty(*args); end
      end

      BUILDER_KEY = :transaction_sample_builder

      attr_accessor :stack_trace_threshold, :random_sampling, :sampling_rate
      attr_reader :samples, :last_sample, :disabled

      def initialize
        # @samples is an array of recent samples up to @max_samples in
        # size - it's only used by developer mode
        @samples = []
        @max_samples = 100

        # @harvest_count is a count of harvests used for random
        # sampling - we pull 1 @random_sample in every @sampling_rate harvests
        @harvest_count = 0
        @random_sample = nil
        @sampling_rate = 10

        # @segment_limit and @stack_trace_threshold come from the
        # configuration file, with built-in defaults that should
        # suffice for most customers
        config = NewRelic::Control.instance
        sampler_config = config.fetch('transaction_tracer', {})
        @segment_limit = sampler_config.fetch('limit_segments', 4000)
        @stack_trace_threshold = sampler_config.fetch('stack_trace_threshold', 0.500).to_f

        # This lock is used to synchronize access to the @last_sample
        # and related variables. It can become necessary on JRuby or
        # any 'honest-to-god'-multithreaded system
        @samples_lock = Mutex.new
      end

      # Returns the current sample id, delegated from `builder`
      def current_sample_id
        b=builder
        b and b.sample_id
      end

      # Enable the transaction sampler - this also registers it with
      # the statistics engine.
      def enable
        @disabled = false
        NewRelic::Agent.instance.stats_engine.transaction_sampler = self
      end

      # Disable the transaction sampler - this also deregisters it
      # with the statistics engine.
      def disable
        @disabled = true
        NewRelic::Agent.instance.stats_engine.remove_transaction_sampler(self)
      end

      # Set with an integer value n, this takes one in every n
      # harvested samples. It also resets the harvest count to a
      # random integer between 0 and (n-1)
      def sampling_rate=(val)
        @sampling_rate = val.to_i
        @harvest_count = rand(val.to_i).to_i
      end


      # Creates a new transaction sample builder, unless the
      # transaction sampler is disabled. Takes a time parameter for
      # the start of the transaction sample
      def notice_first_scope_push(time)
        start_builder(time.to_f) unless disabled
      end

      # This delegates to the builder to create a new open transaction
      # segment for the specified scope, beginning at the optionally
      # specified time.
      #
      # Note that in developer mode, this captures a stacktrace for
      # the beginning of each segment, which can be fairly slow
      def notice_push_scope(scope, time=Time.now)
        return unless builder

        builder.trace_entry(scope, time.to_f)

        capture_segment_trace if NewRelic::Control.instance.developer_mode?
      end

      # in developer mode, capture the stack trace with the segment.
      # this is cpu and memory expensive and therefore should not be
      # turned on in production mode
      def capture_segment_trace
        return unless NewRelic::Control.instance.developer_mode?
        segment = builder.current_segment
        if segment
          # Strip stack frames off the top that match /new_relic/agent/
          trace = caller
          while trace.first =~/\/lib\/new_relic\/agent\//
            trace.shift
          end

          trace = trace[0..39] if trace.length > 40
          segment[:backtrace] = trace
        end
      end

      # Defaults to zero, otherwise delegated to the transaction
      # sample builder
      def scope_depth
        return 0 unless builder

        builder.scope_depth
      end

      # Informs the transaction sample builder about the end of a
      # traced scope
      def notice_pop_scope(scope, time = Time.now)
        return unless builder
        raise "frozen already???" if builder.sample.frozen?
        builder.trace_exit(scope, time.to_f)
      end

      # This is called when we are done with the transaction.  We've
      # unwound the stack to the top level. It also clears the
      # transaction sample builder so that it won't continue to have
      # scopes appended to it.
      #
      # It sets various instance variables to the finished sample,
      # depending on which settings are active. See `store_sample`
      def notice_scope_empty(time=Time.now)

        last_builder = builder
        return unless last_builder

        last_builder.finish_trace(time.to_f)
        clear_builder
        return if last_builder.ignored?

        @samples_lock.synchronize do
          # NB this instance variable may be used elsewhere, it's not
          # just a side effect
          @last_sample = last_builder.sample
          store_sample(@last_sample)
        end
      end

      # Samples can be stored in three places: the random sample
      # variable, when random sampling is active, the developer mode
      # @samples array, and the @slowest_sample variable if it is
      # slower than the current occupant of that slot
      def store_sample(sample)
        store_random_sample(sample)
        store_sample_for_developer_mode(sample)
        store_slowest_sample(sample)
      end

      # Only active when random sampling is true - this is very rarely
      # used. Always store the most recent sample so that random
      # sampling can pick a few of the samples to store, upon harvest
      def store_random_sample(sample)
        if @random_sampling
          @random_sample = sample
        end
      end

      # Samples take up a ton of memory, so we only store a lot of
      # them in developer mode - we truncate to @max_samples
      def store_sample_for_developer_mode(sample)
        return unless NewRelic::Control.instance.developer_mode?
        @samples = [] unless @samples
        @samples << sample
        truncate_samples
      end

      # Sets @slowest_sample to the passed in sample if it is slower
      # than the current sample in @slowest_sample
      def store_slowest_sample(sample)
        @slowest_sample = sample if slowest_sample?(@slowest_sample, sample)
      end

      # Checks to see if the old sample exists, or if it's duration is
      # less than the new sample
      def slowest_sample?(old_sample, new_sample)
        old_sample.nil? || (new_sample.duration > old_sample.duration)
      end

      # Smashes the @samples array down to the length of @max_samples
      # by taking the last @max_samples elements of the array
      def truncate_samples
        if @samples.length > @max_samples
          @samples = @samples[-@max_samples..-1]
        end
      end

      # Delegates to the builder to store the path, uri, and
      # parameters if the sampler is active
      def notice_transaction(path, uri=nil, params={})
        builder.set_transaction_info(path, uri, params) if !disabled && builder
      end

      # Tells the builder to ignore a transaction, if we are currently
      # creating one. Only causes the sample to be ignored upon end of
      # the transaction, and does not change the metrics gathered
      # outside of the sampler
      def ignore_transaction
        builder.ignore_transaction if builder
      end

      # For developer mode profiling support - delegates to the builder
      def notice_profile(profile)
        builder.set_profile(profile) if builder
      end

      # Sets the CPU time used by a transaction, delegates to the builder
      def notice_transaction_cpu_time(cpu_time)
        builder.set_transaction_cpu_time(cpu_time) if builder
      end

      MAX_DATA_LENGTH = 16384
      # This method is used to record metadata into the currently
      # active segment like a sql query, memcache key, or Net::HTTP uri
      #
      # duration is seconds, float value.
      def notice_extra_data(message, duration, key, config=nil, config_key=nil)
        return unless builder
        segment = builder.current_segment
        if segment
          segment[key] = truncate_message(append_new_message(segment[key], message))
          segment[config_key] = config if config_key
          append_backtrace(segment, duration)
        end
      end

      private :notice_extra_data

      # Truncates the message to `MAX_DATA_LENGTH` if needed, and
      # appends an ellipsis because it makes the trucation clearer in
      # the UI
      def truncate_message(message)
        if message.length > (MAX_DATA_LENGTH - 4)
          message[0..MAX_DATA_LENGTH - 4] + '...'
        else
          message
        end
      end

      # Allows the addition of multiple pieces of metadata to one
      # segment - i.e. traced method calls multiple sql queries
      def append_new_message(old_message, message)
        if old_message
          old_message + ";\n" + message
        else
          message
        end
      end

      # Appends a backtrace to a segment if that segment took longer
      # than the specified duration
      def append_backtrace(segment, duration)
        segment[:backtrace] = caller.join("\n") if duration >= @stack_trace_threshold
      end

      # some statements (particularly INSERTS with large BLOBS
      # may be very large; we should trim them to a maximum usable length
      # config is the driver configuration for the connection
      # duration is seconds, float value.
      def notice_sql(sql, config, duration)
        if NewRelic::Agent.is_sql_recorded?
          notice_extra_data(sql, duration, :sql, config, :connection_config)
        end
      end

      # Adds non-sql metadata to a segment - generally the memcached
      # key
      #
      # duration is seconds, float value.
      def notice_nosql(key, duration)
        notice_extra_data(key, duration, :key)
      end

      # Every 1/n harvests, adds the most recent sample to the harvest
      # array if it exists. Makes sure that the random sample is not
      # also the slowest sample for this harvest by `uniq!`ing the
      # result array
      #
      # random sampling is very, very seldom used
      def add_random_sample_to(result)
        return unless @random_sampling && @sampling_rate && @sampling_rate.to_i > 0
        @harvest_count += 1
        if (@harvest_count.to_i % @sampling_rate.to_i) == 0
          result << @random_sample if @random_sample
        end
        result.uniq!
        nil # don't assume this method returns anything
      end

      # Returns an array of slow samples, with either one or two
      # elements - one element unless random sampling is enabled. The
      # sample returned will be the slowest sample among those
      # available during this harvest
      def add_samples_to(result, slow_threshold)
        if @slowest_sample && @slowest_sample.duration >= slow_threshold
          result << @slowest_sample
        end
        result.compact!
        result = result.sort_by { |x| x.duration }
        result = result[-1..-1] || []
        add_random_sample_to(result)
        result
      end

      # get the set of collected samples, merging into previous samples,
      # and clear the collected sample list. Truncates samples to a
      # specified @segment_limit to save memory and bandwith
      # transmitting samples to the server.
      def harvest(previous = [], slow_threshold = 2.0)
        return [] if disabled
        result = Array(previous)
        @samples_lock.synchronize do
          result = add_samples_to(result, slow_threshold)
          # clear previous transaction samples
          @slowest_sample = nil
          @random_sample = nil
          @last_sample = nil
        end
        # Truncate the samples at 2100 segments. The UI will clamp them at 2000 segments anyway.
        # This will save us memory and bandwidth.
        result.each { |sample| sample.truncate(@segment_limit) }
        result
      end

      # reset samples without rebooting the web server
      def reset!
        @samples = []
        @last_sample = nil
        @random_sample = nil
        @slowest_sample = nil
      end

      private

      # Checks to see if the transaction sampler is disabled, if
      # transaction trace recording is disabled by a thread local, or
      # if execution is untraced - if so it clears the transaction
      # sample builder from the thread local, otherwise it generates a
      # new transaction sample builder with the stated time as a
      # starting point and saves it in the thread local variable
      def start_builder(time=nil)
        if disabled || !NewRelic::Agent.is_transaction_traced? || !NewRelic::Agent.is_execution_traced?
          clear_builder
        else
          Thread::current[BUILDER_KEY] ||= TransactionSampleBuilder.new(time)
        end
      end

      # The current thread-local transaction sample builder
      def builder
        Thread::current[BUILDER_KEY]
      end

      # Sets the thread local variable storing the transaction sample
      # builder to nil to clear it
      def clear_builder
        Thread::current[BUILDER_KEY] = nil
      end

    end
  end
end
