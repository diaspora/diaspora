require 'socket'
require 'net/https'
require 'net/http'
require 'logger'
require 'zlib'
require 'stringio'
require 'new_relic/data_serialization'

module NewRelic
  module Agent

    # The Agent is a singleton that is instantiated when the plugin is
    # activated.  It collects performance data from ruby applications
    # in realtime as the application runs, and periodically sends that
    # data to the NewRelic server.
    class Agent

      # Specifies the version of the agent's communication protocol with
      # the NewRelic hosted site.

      PROTOCOL_VERSION = 8
      # 14105: v8 (tag 2.10.3)
      # (no v7)
      # 10379: v6 (not tagged)
      # 4078:  v5 (tag 2.5.4)
      # 2292:  v4 (tag 2.3.6)
      # 1754:  v3 (tag 2.3.0)
      # 534:   v2 (shows up in 2.1.0, our first tag)


      def initialize

        @launch_time = Time.now

        @metric_ids = {}
        @stats_engine = NewRelic::Agent::StatsEngine.new
        @transaction_sampler = NewRelic::Agent::TransactionSampler.new
        @stats_engine.transaction_sampler = @transaction_sampler
        @error_collector = NewRelic::Agent::ErrorCollector.new
        @connect_attempts = 0

        @request_timeout = NewRelic::Control.instance.fetch('timeout', 2 * 60)

        @last_harvest_time = Time.now
        @obfuscator = method(:default_sql_obfuscator)
      end
      
      # contains all the class-level methods for NewRelic::Agent::Agent
      module ClassMethods
        # Should only be called by NewRelic::Control - returns a
        # memoized singleton instance of the agent, creating one if needed
        def instance
          @instance ||= self.new
        end
      end
      
      # Holds all the methods defined on NewRelic::Agent::Agent
      # instances
      module InstanceMethods
        
        # holds a proc that is used to obfuscate sql statements
        attr_reader :obfuscator
        # the statistics engine that holds all the timeslice data
        attr_reader :stats_engine
        # the transaction sampler that handles recording transactions
        attr_reader :transaction_sampler
        # error collector is a simple collection of recorded errors
        attr_reader :error_collector
        # whether we should record raw, obfuscated, or no sql
        attr_reader :record_sql
        # a cached set of metric_ids to save the collector some time -
        # it returns a metric id for every metric name we send it, and
        # in the future we transmit using the metric id only
        attr_reader :metric_ids
        # in theory a set of rules applied by the agent to the output
        # of its metrics. Currently unimplemented
        attr_reader :url_rules
        # a configuration for the Real User Monitoring system -
        # handles things like static setup of the header for inclusion
        # into pages
        attr_reader :beacon_configuration
        
        # Returns the length of the unsent errors array, if it exists,
        # otherwise nil
        def unsent_errors_size
          @unsent_errors.length if @unsent_errors
        end
        
        # Returns the length of the traces array, if it exists,
        # otherwise nil
        def unsent_traces_size
          @traces.length if @traces
        end
        
        # Initializes the unsent timeslice data hash, if needed, and
        # returns the number of keys it contains
        def unsent_timeslice_data
          @unsent_timeslice_data ||= {}
          @unsent_timeslice_data.keys.length
        end

        # fakes out a transaction that did not happen in this process
        # by creating apdex, summary metrics, and recording statistics
        # for the transaction
        # 
        # This method is *deprecated* - it may be removed in future
        # versions of the agent
        def record_transaction(duration_seconds, options={})
          is_error = options['is_error'] || options['error_message'] || options['exception']
          metric = options['metric']
          metric ||= options['uri'] # normalize this with url rules
          raise "metric or uri arguments required" unless metric
          metric_info = NewRelic::MetricParser::MetricParser.for_metric_named(metric)

          if metric_info.is_web_transaction?
            NewRelic::Agent::Instrumentation::MetricFrame.record_apdex(metric_info, duration_seconds, duration_seconds, is_error)
          end
          metrics = metric_info.summary_metrics

          metrics << metric
          metrics.each do |name|
            stats = stats_engine.get_stats_no_scope(name)
            stats.record_data_point(duration_seconds)
          end

          if is_error
            if options['exception']
              e = options['exception']
            elsif options['error_message']
              e = Exception.new options['error_message']
            else
              e = Exception.new 'Unknown Error'
            end
            error_collector.notice_error e, :uri => options['uri'], :metric => metric
          end
          # busy time ?
        end

        # This method should be called in a forked process after a fork.
        # It assumes the parent process initialized the agent, but does
        # not assume the agent started.
        #
        # The call is idempotent, but not re-entrant.
        #
        # * It clears any metrics carried over from the parent process
        # * Restarts the sampler thread if necessary
        # * Initiates a new agent run and worker loop unless that was done
        #   in the parent process and +:force_reconnect+ is not true
        #
        # Options:
        # * <tt>:force_reconnect => true</tt> to force the spawned process to
        #   establish a new connection, such as when forking a long running process.
        #   The default is false--it will only connect to the server if the parent
        #   had not connected.
        # * <tt>:keep_retrying => false</tt> if we try to initiate a new
        #   connection, this tells me to only try it once so this method returns
        #   quickly if there is some kind of latency with the server.
        def after_fork(options={})

          # @connected gets false after we fail to connect or have an error
          # connecting.  @connected has nil if we haven't finished trying to connect.
          # or we didn't attempt a connection because this is the master process

          # log.debug "Agent received after_fork notice in #$$: [#{control.agent_enabled?}; monitor=#{control.monitor_mode?}; connected: #{@connected.inspect}; thread=#{@worker_thread.inspect}]"
          return if !control.agent_enabled? or
            !control.monitor_mode? or
            @connected == false or
            @worker_thread && @worker_thread.alive?

          log.info "Starting the worker thread in #$$ after forking."

          # Clear out stats that are left over from parent process
          reset_stats

          # Don't ever check to see if this is a spawner.  If we're in a forked process
          # I'm pretty sure we're not also forking new instances.
          start_worker_thread(options)
          @stats_engine.start_sampler_thread
        end

        # True if we have initialized and completed 'start'
        def started?
          @started
        end

        # Return nil if not yet connected, true if successfully started
        # and false if we failed to start.
        def connected?
          @connected
        end

        # Attempt a graceful shutdown of the agent, running the worker
        # loop if it exists and is running.
        #
        # Options:
        # :force_send => (true/false) # force the agent to send data
        # before shutting down
        def shutdown(options={})
          run_loop_before_exit = options.fetch(:force_send, false)
          return if not started?
          if @worker_loop
            @worker_loop.run_task if run_loop_before_exit
            @worker_loop.stop

            log.debug "Starting Agent shutdown"

            # if litespeed, then ignore all future SIGUSR1 - it's
            # litespeed trying to shut us down

            if control.dispatcher == :litespeed
              Signal.trap("SIGUSR1", "IGNORE")
              Signal.trap("SIGTERM", "IGNORE")
            end

            begin
              NewRelic::Agent.disable_all_tracing do
                graceful_disconnect
              end
            rescue => e
              log.error e
              log.error e.backtrace.join("\n")
            end
          end
          @started = nil
        end

        # Tells the statistics engine we are starting a new transaction
        def start_transaction
          @stats_engine.start_transaction
        end

        # Tells the statistics engine we are ending a transaction
        def end_transaction
          @stats_engine.end_transaction
        end

        # Sets a thread local variable as to whether we should or
        # should not record sql in the current thread. Returns the
        # previous value, if there is one
        def set_record_sql(should_record)
          prev = Thread::current[:record_sql]
          Thread::current[:record_sql] = should_record
          prev.nil? || prev
        end

        # Sets a thread local variable as to whether we should or
        # should not record transaction traces in the current
        # thread. Returns the previous value, if there is one
        def set_record_tt(should_record)
          prev = Thread::current[:record_tt]
          Thread::current[:record_tt] = should_record
          prev.nil? || prev
        end

        # Push flag indicating whether we should be tracing in this
        # thread. This uses a stack which allows us to disable tracing
        # children of a transaction without affecting the tracing of
        # the whole transaction
        def push_trace_execution_flag(should_trace=false)
          value = Thread.current[:newrelic_untraced]
          if (value.nil?)
            Thread.current[:newrelic_untraced] = []
          end

          Thread.current[:newrelic_untraced] << should_trace
        end

        # Pop the current trace execution status.  Restore trace execution status
        # to what it was before we pushed the current flag.
        def pop_trace_execution_flag
          Thread.current[:newrelic_untraced].pop if Thread.current[:newrelic_untraced]
        end

        # Sets the sql obfuscator used to clean up sql when sending it
        # to the server. Possible types are:
        #
        # :before => sets the block to run before the existing
        # obfuscators
        #
        # :after => sets the block to run after the existing
        # obfuscator(s)
        #
        # :replace => removes the current obfuscator and replaces it
        # with the provided block
        def set_sql_obfuscator(type, &block)
          if type == :before
            @obfuscator = NewRelic::ChainedCall.new(block, @obfuscator)
          elsif type == :after
            @obfuscator = NewRelic::ChainedCall.new(@obfuscator, block)
          elsif type == :replace
            @obfuscator = block
          else
            fail "unknown sql_obfuscator type #{type}"
          end
        end

        # Shorthand to the NewRelic::Agent.logger method
        def log
          NewRelic::Agent.logger
        end

        # Herein lies the corpse of the former 'start' method. May
        # it's unmatched flog score rest in pieces.
        module Start
          # Check whether we have already started, which is an error condition
          def already_started?
            if started?
              control.log!("Agent Started Already!", :error)
              true
            end
          end

          # The agent is disabled when it is not force enabled by the
          # 'agent_enabled' option (e.g. in a manual start), or
          # enabled normally through the configuration file
          def disabled?
            !control.agent_enabled?
          end

          # Logs the dispatcher to the log file to assist with
          # debugging. When no debugger is present, logs this fact to
          # assist with proper dispatcher detection
          def log_dispatcher
            dispatcher_name = control.dispatcher.to_s
            return if log_if(dispatcher_name.empty?, :info, "No dispatcher detected.")
            log.info "Dispatcher: #{dispatcher_name}"
          end

          # Logs the configured application names
          def log_app_names
            log.info "Application: #{control.app_names.join(", ")}"
          end
          
          # apdex_f is always 4 times the apdex_t
          def apdex_f
            (4 * NewRelic::Control.instance.apdex_t).to_f
          end

          # If the transaction threshold is set to the string
          # 'apdex_f', we use 4 times the apdex_t value to record
          # transactions. This gears well with using apdex since you
          # will attempt to send any transactions that register as 'failing'
          def apdex_f_threshold?
            sampler_config.fetch('transaction_threshold', '') =~ /apdex_f/i
          end

          # Sets the sql recording configuration by trying to detect
          # any attempt to disable the sql collection - 'off',
          # 'false', 'none', and friends. Otherwise, we accept 'raw',
          # and unrecognized values default to 'obfuscated'
          def set_sql_recording!
            record_sql_config = sampler_config.fetch('record_sql', :obfuscated)
            case record_sql_config.to_s
            when 'off'
              @record_sql = :off
            when 'none'
              @record_sql = :off
            when 'false'
              @record_sql = :off
            when 'raw'
              @record_sql = :raw
            else
              @record_sql = :obfuscated
            end

            log_sql_transmission_warning?
          end

          # Warn the user when we are sending raw sql across the wire
          # - they should probably be using ssl when this is true
          def log_sql_transmission_warning?
            log_if((@record_sql == :raw), :warn, "Agent is configured to send raw SQL to the service")
          end

          # gets the sampler configuration from the control object's settings
          def sampler_config
            control.fetch('transaction_tracer', {})
          end

          # this entire method should be done on the transaction
          # sampler object, rather than here. We should pass in the
          # sampler config.
          def config_transaction_tracer
            @should_send_samples = @config_should_send_samples = sampler_config.fetch('enabled', true)
            @should_send_random_samples = sampler_config.fetch('random_sample', false)
            @explain_threshold = sampler_config.fetch('explain_threshold', 0.5).to_f
            @explain_enabled = sampler_config.fetch('explain_enabled', true)
            set_sql_recording!

            # default to 2.0, string 'apdex_f' will turn into your
            # apdex * 4
            @slowest_transaction_threshold = sampler_config.fetch('transaction_threshold', 2.0).to_f
            @slowest_transaction_threshold = apdex_f if apdex_f_threshold?
          end

          # Connecting in the foreground blocks further startup of the
          # agent until we have a connection - useful in cases where
          # you're trying to log a very-short-running process and want
          # to get statistics from before a server connection
          # (typically 20 seconds) exists
          def connect_in_foreground
            NewRelic::Agent.disable_all_tracing { connect(:keep_retrying => false) }
          end

          # Are we in boss mode, using rubinius?
          def using_rubinius?
            RUBY_VERSION =~ /rubinius/i
          end

          # Is this really a world-within-a-world, running JRuby?
          def using_jruby?
            defined?(JRuby)
          end

          # If we're using sinatra, old versions run in an at_exit
          # block so we should probably know that
          def using_sinatra?
            defined?(Sinatra::Application)
          end

          # we should not set an at_exit block if people are using
          # these as they don't do standard at_exit behavior per MRI/YARV
          def weird_ruby?
            using_rubinius? || using_jruby? || using_sinatra?
          end

          # Installs our exit handler, which exploits the weird
          # behavior of at_exit blocks to make sure it runs last, by
          # doing an at_exit within an at_exit block.
          def install_exit_handler
            if control.send_data_on_exit && !weird_ruby?
              # Our shutdown handler needs to run after other shutdown handlers
              at_exit { at_exit { shutdown } }
            end
          end

          # Tells us in the log file where the log file is
          # located. This seems redundant, but can come in handy when
          # we have some log file path set by the user which parses
          # incorrectly, sending the log file to who-knows-where
          def notify_log_file_location
            log_file = NewRelic::Control.instance.log_file
            log_if(File.exists?(log_file.to_s), :info,
                   "Agent Log at #{log_file}")
          end

          # Classy logging of the agent version and the current pid,
          # so we can disambiguate processes in the log file and make
          # sure they're running a reasonable version
          def log_version_and_pid
            log.info "New Relic Ruby Agent #{NewRelic::VERSION::STRING} Initialized: pid = #{$$}"
          end

          # A helper method that logs a condition if that condition is
          # true. Mentally cleaner than having every method set a
          # local and log if it is true
          def log_if(boolean, level, message)
            self.log.send(level, message) if boolean
            boolean
          end

          # A helper method that logs a condition unless that
          # condition is true. Mentally cleaner than having every
          # method set a local and log unless it is true
          def log_unless(boolean, level, message)
            self.log.send(level, message) unless boolean
            boolean
          end

          # Warn the user if they have configured their agent not to
          # send data, that way we can see this clearly in the log file
          def monitoring?
            log_unless(control.monitor_mode?, :warn, "Agent configured not to send data in this environment - edit newrelic.yml to change this")
          end

          # Tell the user when the license key is missing so they can
          # fix it by adding it to the file
          def has_license_key?
            log_unless(control.license_key, :error, "No license key found.  Please edit your newrelic.yml file and insert your license key.")
          end

          # A correct license key exists and is of the proper length
          def has_correct_license_key?
            has_license_key? && correct_license_length
          end

          # A license key is an arbitrary 40 character string,
          # usually looks something like a SHA1 hash
          def correct_license_length
            key = control.license_key
            log_unless((key.length == 40), :error, "Invalid license key: #{key}")
          end

          # If we're using a dispatcher that forks before serving
          # requests, we need to wait until the children are forked
          # before connecting, otherwise the parent process sends odd data
          def using_forking_dispatcher?
            log_if([:passenger, :unicorn].include?(control.dispatcher), :info, "Connecting workers after forking.")
          end

          # Sanity-check the agent configuration and start the agent,
          # setting up the worker thread and the exit handler to shut
          # down the agent
          def check_config_and_start_agent
            return unless monitoring? && has_correct_license_key?
            return if using_forking_dispatcher?
            connect_in_foreground if control.sync_startup
            start_worker_thread
            install_exit_handler
          end
        end

        include Start

        # Logs a bunch of data and starts the agent, if needed
        def start
          return if already_started? || disabled?
          @started = true
          @local_host = determine_host
          log_dispatcher
          log_app_names
          config_transaction_tracer
          check_config_and_start_agent
          log_version_and_pid
          notify_log_file_location
        end

        # Clear out the metric data, errors, and transaction traces,
        # making sure the agent is in a fresh state
        def reset_stats
          @stats_engine.reset_stats
          @unsent_errors = []
          @traces = nil
          @unsent_timeslice_data = {}
          @last_harvest_time = Time.now
          @launch_time = Time.now
        end

        private
        def collector
          @collector ||= control.server
        end
        
        # All of this module used to be contained in the
        # start_worker_thread method - this is an artifact of
        # refactoring and can be moved, renamed, etc at will
        module StartWorkerThread

          # disable transaction sampling if disabled by the server
          # and we're not in dev mode
          def check_transaction_sampler_status
            if control.developer_mode? || @should_send_samples
              @transaction_sampler.enable
            else
              @transaction_sampler.disable
            end
          end
          
          # logs info about the worker loop so users can see when the
          # agent actually begins running in the background
          def log_worker_loop_start
            log.info "Reporting performance data every #{@report_period} seconds."
            log.debug "Running worker loop"
          end

          # Creates the worker loop and loads it with the instructions
          # it should run every @report_period seconds
          def create_and_run_worker_loop
            @worker_loop = WorkerLoop.new
            @worker_loop.run(@report_period) do
              save_or_transmit_data
            end
          end

          # Handles the case where the server tells us to restart -
          # this clears the data, clears connection attempts, and
          # waits a while to reconnect.
          def handle_force_restart(error)
            log.info error.message
            reset_stats
            @metric_ids = {}
            @connected = nil
            sleep 30
          end

          # when a disconnect is requested, stop the current thread, which
          # is the worker thread that gathers data and talks to the
          # server.
          def handle_force_disconnect(error)
            log.error "New Relic forced this agent to disconnect (#{error.message})"
            disconnect
          end

          # there is a problem with connecting to the server, so we
          # stop trying to connect and shut down the agent
          def handle_server_connection_problem(error)
            log.error "Unable to establish connection with the server.  Run with log level set to debug for more information."
            log.debug("#{error.class.name}: #{error.message}\n#{error.backtrace.first}")
            disconnect
          end

          # Handles an unknown error in the worker thread by logging
          # it and disconnecting the agent, since we are now in an
          # unknown state
          def handle_other_error(error)
            log.error "Terminating worker loop: #{error.class.name}: #{error.message}\n  #{error.backtrace.join("\n  ")}"
            disconnect
          end

          # a wrapper method to handle all the errors that can happen
          # in the connection and worker thread system. This
          # guarantees a no-throw from the background thread.
          def catch_errors
            yield
          rescue NewRelic::Agent::ForceRestartException => e
            handle_force_restart(e)
            retry
          rescue NewRelic::Agent::ForceDisconnectException => e
            handle_force_disconnect(e)
          rescue NewRelic::Agent::ServerConnectionException => e
            handle_server_connection_problem(e)
          rescue Exception => e
            handle_other_error(e)
          end

          # This is the method that is run in a new thread in order to
          # background the harvesting and sending of data during the
          # normal operation of the agent.
          #
          # Takes connection options that determine how we should
          # connect to the server, and loops endlessly - typically we
          # never return from this method unless we're shutting down
          # the agent
          def deferred_work!(connection_options)
            catch_errors do
              NewRelic::Agent.disable_all_tracing do
                # We try to connect.  If this returns false that means
                # the server rejected us for a licensing reason and we should
                # just exit the thread.  If it returns nil
                # that means it didn't try to connect because we're in the master.
                connect(connection_options)
                if @connected
                  check_transaction_sampler_status
                  log_worker_loop_start
                  create_and_run_worker_loop
                  # never reaches here unless there is a problem or
                  # the agent is exiting
                else
                  log.debug "No connection.  Worker thread ending."
                end
              end
            end
          end
        end
        include StartWorkerThread

        # Try to launch the worker thread and connect to the server.
        #
        # See #connect for a description of connection_options.
        def start_worker_thread(connection_options = {})
          log.debug "Creating Ruby Agent worker thread."
          @worker_thread = Thread.new do
            deferred_work!(connection_options)
          end # thread new
          @worker_thread['newrelic_label'] = 'Worker Loop'
        end

        # A shorthand for NewRelic::Control.instance
        def control
          NewRelic::Control.instance
        end
        
        # This module is an artifact of a refactoring of the connect
        # method - all of its methods are used in that context, so it
        # can be refactored at will. It should be fully tested
        module Connect
          # the frequency with which we should try to connect to the
          # server at the moment.
          attr_accessor :connect_retry_period
          # number of attempts we've made to contact the server
          attr_accessor :connect_attempts

          # Disconnect just sets connected to false, which prevents
          # the agent from trying to connect again
          def disconnect
            @connected = false
            true
          end

          # We've tried to connect if @connected is not nil, or if we
          # are forcing reconnection (i.e. in the case of an
          # after_fork with long running processes)
          def tried_to_connect?(options)
            !(@connected.nil? || options[:force_reconnect])
          end

          # We keep trying by default, but you can disable it with the
          # :keep_retrying option set to false
          def should_keep_retrying?(options)
            @keep_retrying = (options[:keep_retrying].nil? || options[:keep_retrying])
          end

          # Retry period is a minute for each failed attempt that
          # we've made. This should probably do some sort of sane TCP
          # backoff to prevent hammering the server, but a minute for
          # each attempt seems to work reasonably well.
          def get_retry_period
            return 600 if self.connect_attempts > 6
            connect_attempts * 60
          end

          def increment_retry_period! #:nodoc:
            self.connect_retry_period=(get_retry_period)
          end

          # We should only retry when there has not been a more
          # serious condition that would prevent it. We increment the
          # connect attempts and the retry period, to prevent constant
          # connection attempts, and tell the user what we're doing by
          # logging.
          def should_retry?
            if @keep_retrying
              self.connect_attempts=(connect_attempts + 1)
              increment_retry_period!
              log.info "Will re-attempt in #{connect_retry_period} seconds"
              true
            else
              disconnect
              false
            end
          end

          # When we have a problem connecting to the server, we need
          # to tell the user what happened, since this is not an error
          # we can handle gracefully.
          def log_error(error)
            log.error "Error establishing connection with New Relic Service at #{control.server}: #{error.message}"
            log.debug error.backtrace.join("\n")
          end

          # When the server sends us an error with the license key, we
          # want to tell the user that something went wrong, and let
          # them know where to go to get a valid license key
          #
          # After this runs, it disconnects the agent so that it will
          # no longer try to connect to the server, saving the
          # application and the server load
          def handle_license_error(error)
            log.error error.message
            log.info "Visit NewRelic.com to obtain a valid license key, or to upgrade your account."
            disconnect
          end

          # If we are using a seed and token to validate the agent, we
          # should debug log that fact so that debug logs include a
          # clue that token authentication is what will be used
          def log_seed_token
            if control.validate_seed
              log.debug "Connecting with validation seed/token: #{control.validate_seed}/#{control.validate_token}"
            end
          end

          # Checks whether we should send environment info, and if so,
          # returns the snapshot from the local environment
          def environment_for_connect
            control['send_environment_info'] != false ? control.local_env.snapshot : []
          end

          # These validation settings are used for cases where a
          # dynamic server is spun up for clients - partners can
          # include a seed and token to indicate that the host is
          # allowed to connect, rather than setting a unique hostname
          def validate_settings
            {
              :seed => control.validate_seed,
              :token => control.validate_token
            }
          end

          # Initializes the hash of settings that we send to the
          # server. Returns a literal hash containing the options
          def connect_settings
            {
              :pid => $$,
              :host => @local_host,
              :app_name => control.app_names,
              :language => 'ruby',
              :agent_version => NewRelic::VERSION::STRING,
              :environment => environment_for_connect,
              :settings => control.settings,
              :validate => validate_settings
            }
          end

          # Does some simple logging to make sure that our seed and
          # token for verification are correct, then returns the
          # connect data passed back from the server
          def connect_to_server
            log_seed_token
            connect_data = invoke_remote(:connect, connect_settings)
          end

          # Configures the error collector if the server says that we
          # are allowed to send errors. Pretty simple, and logs at
          # debug whether errors will or will not be sent.
          def configure_error_collector!(server_enabled)
            # Ask for permission to collect error data
            enabled = if error_collector.config_enabled && server_enabled
                        error_collector.enabled = true
                      else
                        error_collector.enabled = false
                      end
            log.debug "Errors will #{enabled ? '' : 'not '}be sent to the New Relic service."
          end

          # Random sampling is enabled based on a sample rate, which
          # is the n in "every 1/n transactions is added regardless of
          # its length".
          #
          # uses a sane default for sampling rate if the sampling rate
          # is zero, since the collector currently sends '0' as a
          # sampling rate for all accounts, which is probably for
          # legacy reasons
          def enable_random_samples!(sample_rate)
            sample_rate = 10 unless sample_rate.to_i > 0
            @transaction_sampler.random_sampling = true
            @transaction_sampler.sampling_rate = sample_rate
            log.info "Transaction sampling enabled, rate = #{@transaction_sampler.sampling_rate}"
          end

          # Enables or disables the transaction tracer and sets its
          # options based on the options provided to the
          # method.
          def configure_transaction_tracer!(server_enabled, sample_rate)
            # Ask the server for permission to send transaction samples.
            # determined by subscription license.
            @should_send_samples = @config_should_send_samples && server_enabled

            if @should_send_samples
              # I don't think this is ever true, but...
              enable_random_samples!(sample_rate) if @should_send_random_samples
              log.debug "Transaction tracing threshold is #{@slowest_transaction_threshold} seconds."
            else
              log.debug "Transaction traces will not be sent to the New Relic service."
            end
          end

          # Asks the collector to tell us which sub-collector we
          # should be reporting to, and then does the name resolution
          # on that host so we don't block on DNS during the normal
          # course of agent processing
          def set_collector_host!
            host = invoke_remote(:get_redirect_host)
            if host
              @collector = control.server_from_host(host)
            end
          end

          # Sets the collector host and connects to the server, then
          # invokes the final configuration with the returned data
          def query_server_for_configuration
            set_collector_host!

            finish_setup(connect_to_server)
          end

          # Takes a hash of configuration data returned from the
          # server and uses it to set local variables and to
          # initialize various parts of the agent that are configured
          # separately.
          #
          # Can accommodate most arbitrary data - anything extra is
          # ignored unless we say to do something with it here.
          def finish_setup(config_data)
            @agent_id = config_data['agent_run_id']
            @report_period = config_data['data_report_period']
            @url_rules = config_data['url_rules']
            @beacon_configuration = BeaconConfiguration.new(config_data)

            log_connection!(config_data)
            configure_transaction_tracer!(config_data['collect_traces'], config_data['sample_rate'])
            configure_error_collector!(config_data['collect_errors'])
          end
          
          # Logs when we connect to the server, for debugging purposes
          # - makes sure we know if an agent has not connected
          def log_connection!(config_data)
            control.log! "Connected to NewRelic Service at #{@collector}"
            log.debug "Agent Run       = #{@agent_id}."
            log.debug "Connection data = #{config_data.inspect}"
          end
        end
        include Connect


        # Serialize all the important data that the agent might want
        # to send to the server. We could be sending this to file (
        # common in short-running background transactions ) or
        # alternately we could serialize via a pipe or socket to a
        # local aggregation device
        def serialize
          accumulator = []
          accumulator[1] = harvest_transaction_traces if @transaction_sampler
          accumulator[2] = harvest_errors if @error_collector
          accumulator[0] = harvest_timeslice_data
          reset_stats
          @metric_ids = {}
          accumulator
        end
        public :serialize

        # Accepts data as provided by the serialize method and merges
        # it into our current collection of data to send. Can be
        # dangerous if we re-merge the same data more than once - it
        # will be sent multiple times.
        def merge_data_from(data)
          metrics, transaction_traces, errors = data
          @stats_engine.merge_data(metrics) if metrics
          if transaction_traces
            if @traces
              @traces = @traces + transaction_traces
            else
              @traces = transaction_traces
            end
          end
          if errors
            if @unsent_errors
              @unsent_errors = @unsent_errors + errors
            else
              @unsent_errors = errors
            end
          end
        end

        public :merge_data_from

        # Connect to the server and validate the license.  If successful,
        # @connected has true when finished.  If not successful, you can
        # keep calling this.  Return false if we could not establish a
        # connection with the server and we should not retry, such as if
        # there's a bad license key.
        #
        # Set keep_retrying=false to disable retrying and return asap, such as when
        # invoked in the foreground.  Otherwise this runs until a successful
        # connection is made, or the server rejects us.
        #
        # * <tt>:keep_retrying => false</tt> to only try to connect once, and
        #   return with the connection set to nil.  This ensures we may try again
        #   later (default true).
        # * <tt>force_reconnect => true</tt> if you want to establish a new connection
        #   to the server before running the worker loop.  This means you get a separate
        #   agent run and New Relic sees it as a separate instance (default is false).
        def connect(options)
          # Don't proceed if we already connected (@connected=true) or if we tried
          # to connect and were rejected with prejudice because of a license issue
          # (@connected=false), unless we're forced to by force_reconnect.
          return if tried_to_connect?(options)

          # wait a few seconds for the web server to boot, necessary in development
          @connect_retry_period = should_keep_retrying?(options) ? 10 : 0

          sleep connect_retry_period
          log.debug "Connecting Process to New Relic: #$0"
          query_server_for_configuration
          @connected_pid = $$
          @connected = true
        rescue NewRelic::Agent::LicenseException => e
          handle_license_error(e)
        rescue Timeout::Error, StandardError => e
          log_error(e)
          if should_retry?
            retry
          else
            disconnect
          end
        end

        # Who am I? Well, this method can tell you your hostname.
        def determine_host
          Socket.gethostname
        end

        # Delegates to the control class to determine the root
        # directory of this project
        def determine_home_directory
          control.root
        end

        # Checks whether this process is a Passenger or Unicorn
        # spawning server - if so, we probably don't intend to report
        # statistics from this process
        def is_application_spawner?
          $0 =~ /ApplicationSpawner|^unicorn\S* master/
        end

        # calls the busy harvester and collects timeslice data to
        # send later
        def harvest_timeslice_data(time=Time.now)
          # this creates timeslices that are harvested below
          NewRelic::Agent::BusyCalculator.harvest_busy

          @unsent_timeslice_data ||= {}
          @unsent_timeslice_data = @stats_engine.harvest_timeslice_data(@unsent_timeslice_data, @metric_ids)
          @unsent_timeslice_data
        end

        # takes an array of arrays of spec and id, adds it into the
        # metric cache so we can save the collector some work by
        # sending integers instead of strings
        def fill_metric_id_cache(pairs_of_specs_and_ids)
          Array(pairs_of_specs_and_ids).each do |metric_spec, metric_id|
            @metric_ids[metric_spec] = metric_id
          end
        end

        # note - exceptions are logged in invoke_remote.  If an exception is encountered here,
        # then the metric data is downsampled for another
        # transmission later
        def harvest_and_send_timeslice_data
          now = Time.now
          NewRelic::Agent.instance.stats_engine.get_stats_no_scope('Supportability/invoke_remote').record_data_point(0.0)
          NewRelic::Agent.instance.stats_engine.get_stats_no_scope('Supportability/invoke_remote/metric_data').record_data_point(0.0)
          harvest_timeslice_data(now)
          begin
            # In this version of the protocol, we get back an assoc array of spec to id.
            metric_specs_and_ids = invoke_remote(:metric_data, @agent_id,
                                                 @last_harvest_time.to_f,
                                                 now.to_f,
                                                 @unsent_timeslice_data.values)

          rescue Timeout::Error
            # assume that the data was received. chances are that it
            # was. Also, lol.
            metric_specs_and_ids = []
          end

          fill_metric_id_cache(metric_specs_and_ids)

          log.debug "#{now}: sent #{@unsent_timeslice_data.length} timeslices (#{@agent_id}) in #{Time.now - now} seconds"

          # if we successfully invoked this web service, then clear the unsent message cache.
          @unsent_timeslice_data = {}
          @last_harvest_time = now
        end

        # Fills the traces array with the harvested transactions from
        # the transaction sampler, subject to the setting for slowest
        # transaction threshold
        def harvest_transaction_traces
          @traces = @transaction_sampler.harvest(@traces, @slowest_transaction_threshold)
          @traces
        end

        # This handles getting the transaction traces and then sending
        # them across the wire.  This includes gathering SQL
        # explanations, stripping out stack traces, and normalizing
        # SQL.  note that we explain only the sql statements whose
        # segments' execution times exceed our threshold (to avoid
        # unnecessary overhead of running explains on fast queries.)
        def harvest_and_send_slowest_sample
          harvest_transaction_traces
          unless @traces.empty?
            now = Time.now
            log.debug "Sending (#{@traces.length}) transaction traces"
            begin
              options = { :keep_backtraces => true }
              options[:record_sql] = @record_sql unless @record_sql == :off
              options[:explain_sql] = @explain_threshold if @explain_enabled
              traces = @traces.collect {|trace| trace.prepare_to_send(options)}
              invoke_remote :transaction_sample_data, @agent_id, traces
            rescue PostTooBigException
              # we tried to send too much data, drop the first trace and
              # try again
              retry if @traces.shift
            end

            log.debug "Sent slowest sample (#{@agent_id}) in #{Time.now - now} seconds"
          end

          # if we succeed sending this sample, then we don't need to keep
          # the slowest sample around - it has been sent already and we
          # can clear the collection and move on
          @traces = nil
        end

        # Gets the collection of unsent errors from the error
        # collector. We pass back in an existing array of errors that
        # may be left over from a previous send
        def harvest_errors
          @unsent_errors = @error_collector.harvest_errors(@unsent_errors)
          @unsent_errors
        end

        # Handles getting the errors from the error collector and
        # sending them to the server, and any error cases like trying
        # to send very large errors - we drop the oldest error on the
        # floor and try again
        def harvest_and_send_errors
          harvest_errors
          if @unsent_errors && @unsent_errors.length > 0
            log.debug "Sending #{@unsent_errors.length} errors"
            begin
              invoke_remote :error_data, @agent_id, @unsent_errors
            rescue PostTooBigException
              @unsent_errors.shift
              retry
            end
            # if the remote invocation fails, then we never clear
            # @unsent_errors, and therefore we can re-attempt to send on
            # the next heartbeat.  Note the error collector maxes out at
            # 20 instances to prevent leakage
            @unsent_errors = []
          end
        end

        # This method handles the compression of the request body that
        # we are going to send to the server
        #
        # We currently optimize for CPU here since we get roughly a 10x
        # reduction in message size with this, and CPU overhead is at a
        # premium. For extra-large posts, we use the higher compression
        # since otherwise it actually errors out.
        #
        # We do not compress if content is smaller than 64kb.  There are
        # problems with bugs in Ruby in some versions that expose us
        # to a risk of segfaults if we compress aggressively.
        #
        # medium payloads get fast compression, to save CPU
        # big payloads get all the compression possible, to stay under
        # the 2,000,000 byte post threshold
        def compress_data(object)
          dump = Marshal.dump(object)

          # this checks to make sure mongrel won't choke on big uploads
          check_post_size(dump)

          dump_size = dump.size

          return [dump, 'identity'] if dump_size < (64*1024)

          compression = dump_size < 2000000 ? Zlib::BEST_SPEED : Zlib::BEST_COMPRESSION

          [Zlib::Deflate.deflate(dump, compression), 'deflate']
        end

        # Raises a PostTooBigException if the post_string is longer
        # than the limit configured in the control object
        def check_post_size(post_string)
          # TODO: define this as a config option on the server side
          return if post_string.size < control.post_size_limit
          log.warn "Tried to send too much data: #{post_string.size} bytes"
          raise PostTooBigException
        end

        # Posts to the specified server
        #
        # Options:
        #  - :uri => the path to request on the server (a misnomer of
        #              course)
        #  - :encoding => the encoding to pass to the server
        #  - :collector => a URI object that responds to the 'name' method
        #                    and returns the name of the collector to
        #                    contact
        #  - :data => the data to send as the body of the request
        def send_request(opts)
          request = Net::HTTP::Post.new(opts[:uri], 'CONTENT-ENCODING' => opts[:encoding], 'HOST' => opts[:collector].name)
          request['user-agent'] = user_agent
          request.content_type = "application/octet-stream"
          request.body = opts[:data]

          log.debug "Connect to #{opts[:collector]}#{opts[:uri]}"

          response = nil
          http = control.http_connection(collector)
          http.read_timeout = nil
          begin
            NewRelic::TimerLib.timeout(@request_timeout) do
              response = http.request(request)
            end
          rescue Timeout::Error
            log.warn "Timed out trying to post data to New Relic (timeout = #{@request_timeout} seconds)" unless @request_timeout < 30
            raise
          end
          if response.is_a? Net::HTTPServiceUnavailable
            raise NewRelic::Agent::ServerConnectionException, "Service unavailable (#{response.code}): #{response.message}"
          elsif response.is_a? Net::HTTPGatewayTimeOut
            log.debug("Timed out getting response: #{response.message}")
            raise Timeout::Error, response.message
          elsif response.is_a? Net::HTTPRequestEntityTooLarge
            raise PostTooBigException
          elsif !(response.is_a? Net::HTTPSuccess)
            raise NewRelic::Agent::ServerConnectionException, "Unexpected response from server (#{response.code}): #{response.message}"
          end
          response
        end

        # Decompresses the response from the server, if it is gzip
        # encoded, otherwise returns it verbatim
        def decompress_response(response)
          if response['content-encoding'] != 'gzip'
            log.debug "Uncompressed content returned"
            return response.body
          end
          log.debug "Decompressing return value"
          i = Zlib::GzipReader.new(StringIO.new(response.body))
          i.read
        end

        # unmarshals the response and raises it if it is an exception,
        # so we can handle it in nonlocally
        def check_for_exception(response)
          dump = decompress_response(response)
          value = Marshal.load(dump)
          raise value if value.is_a? Exception
          value
        end

        # The path on the server that we should post our data to
        def remote_method_uri(method)
          uri = "/agent_listener/#{PROTOCOL_VERSION}/#{control.license_key}/#{method}"
          uri << "?run_id=#{@agent_id}" if @agent_id
          uri
        end

        # Sets the user agent for connections to the server, to
        # conform with the HTTP spec and allow for debugging. Includes
        # the ruby version and also zlib version if available since
        # that may cause corrupt compression if there is a problem.
        def user_agent
          ruby_description = ''
          # note the trailing space!
          ruby_description << "(ruby #{::RUBY_VERSION} #{::RUBY_PLATFORM}) " if defined?(::RUBY_VERSION) && defined?(::RUBY_PLATFORM)
          zlib_version = ''
          zlib_version << "zlib/#{Zlib.zlib_version}" if defined?(::Zlib) && Zlib.respond_to?(:zlib_version)
          "NewRelic-RubyAgent/#{NewRelic::VERSION::STRING} #{ruby_description}#{zlib_version}"
        end

        # send a message via post to the actual server. This attempts
        # to automatically compress the data via zlib if it is large
        # enough to be worth compressing, and handles any errors the
        # server may return
        def invoke_remote(method, *args)
          now = Time.now
          #determines whether to zip the data or send plain
          post_data, encoding = compress_data(args)

          response = send_request({:uri => remote_method_uri(method), :encoding => encoding, :collector => collector, :data => post_data})

          # raises the right exception if the remote server tells it to die
          return check_for_exception(response)
        rescue NewRelic::Agent::ForceRestartException => e
          log.info e.message
          raise
        rescue SystemCallError, SocketError => e
          # These include Errno connection errors
          raise NewRelic::Agent::ServerConnectionException, "Recoverable error connecting to the server: #{e}"
        ensure
          NewRelic::Agent.instance.stats_engine.get_stats_no_scope('Supportability/invoke_remote').record_data_point((Time.now - now).to_f)
          NewRelic::Agent.instance.stats_engine.get_stats_no_scope('Supportability/invoke_remote/' + method.to_s).record_data_point((Time.now - now).to_f)
        end

        def save_or_transmit_data
          if NewRelic::DataSerialization.should_send_data?
            log.debug "Sending data to New Relic Service"
            NewRelic::Agent.load_data
            harvest_and_send_errors
            harvest_and_send_slowest_sample
            harvest_and_send_timeslice_data
          else
            log.debug "Serializing agent data to disk"
            NewRelic::Agent.save_data
          end
        end

        # This method contacts the server to send remaining data and
        # let the server know that the agent is shutting down - this
        # allows us to do things like accurately set the end of the
        # lifetime of the process
        #
        # If this process comes from a parent process, it will not
        # disconnect, so that the parent process can continue to send data
        def graceful_disconnect
          if @connected
            begin
              @request_timeout = 10
              save_or_transmit_data
              if @connected_pid == $$
                log.debug "Sending New Relic service agent run shutdown message"
                invoke_remote :shutdown, @agent_id, Time.now.to_f
              else
                log.debug "This agent connected from parent process #{@connected_pid}--not sending shutdown"
              end
              log.debug "Graceful disconnect complete"
            rescue Timeout::Error, StandardError
            end
          else
            log.debug "Bypassing graceful disconnect - agent not connected"
          end
        end
        def default_sql_obfuscator(sql)
          sql = sql.dup
          # This is hardly readable.  Use the unit tests.
          # remove single quoted strings:
          sql.gsub!(/'(.*?[^\\'])??'(?!')/, '?')
          # remove double quoted strings:
          sql.gsub!(/"(.*?[^\\"])??"(?!")/, '?')
          # replace all number literals
          sql.gsub!(/\d+/, "?")
          sql
        end
      end

      extend ClassMethods
      include InstanceMethods
      include BrowserMonitoring
    end
  end
end
