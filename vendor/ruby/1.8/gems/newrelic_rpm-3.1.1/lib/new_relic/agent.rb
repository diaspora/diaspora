require 'new_relic/control'
require 'new_relic/data_serialization'
# = New Relic Ruby Agent
#
# New Relic is a performance monitoring application for applications
# running in production.  For more information on New Relic please visit
# http://www.newrelic.com.
#
# The New Relic Ruby Agent can be installed in Rails applications to
# gather runtime performance metrics, traces, and errors for display
# in a Developer Mode middleware (mapped to /newrelic in your application
# server) or for monitoring and analysis at http://rpm.newrelic.com
# with just about any Ruby application.
#
# == Getting Started
# For instructions on installation and setup, see
# the README[link:./files/README_rdoc.html] file.
#
# == Using with Rack/Metal
#
# To instrument Rack middlwares or Metal apps, refer to the docs in
# NewRelic::Agent::Instrumentation::Rack.
#
# == Ruby Agent API
#
# For details on the Ruby Agent API, refer to NewRelic::Agent.
#
# == Customizing the Ruby Agent
#
# For detailed information on customizing the Ruby Agent
# please visit our {support and documentation site}[http://support.newrelic.com].
#
module NewRelic
  # == Ruby Agent APIs
  # This module contains the public API methods for the Ruby Agent.
  #
  # For adding custom instrumentation to method invocations, refer to
  # the docs in the class NewRelic::Agent::MethodTracer.
  #
  # For information on how to customize the controller
  # instrumentation, or to instrument something other than Rails so
  # that high level dispatcher actions or background tasks show up as
  # first class operations in New Relic, refer to
  # NewRelic::Agent::Instrumentation::ControllerInstrumentation and
  # NewRelic::Agent::Instrumentation::ControllerInstrumentation::ClassMethods.
  #
  # Methods in this module as well as documented methods in
  # NewRelic::Agent::MethodTracer and
  # NewRelic::Agent::Instrumentation::ControllerInstrumentation are
  # available to applications.  When the agent is not enabled the
  # method implementations are stubbed into no-ops to reduce overhead.
  #
  # Methods and classes in other parts of the agent are not guaranteed
  # to be available between releases.
  #
  # Refer to the online docs at support.newrelic.com to see how to
  # access the data collected by custom instrumentation, or e-mail
  # support at New Relic for help.
  module Agent
    extend self

    require 'new_relic/version'
    require 'new_relic/local_environment'
    require 'new_relic/stats'
    require 'new_relic/metrics'
    require 'new_relic/metric_spec'
    require 'new_relic/metric_data'
    require 'new_relic/collection_helper'
    require 'new_relic/transaction_analysis'
    require 'new_relic/transaction_sample'
    require 'new_relic/url_rule'
    require 'new_relic/noticed_error'
    require 'new_relic/timer_lib'

    require 'new_relic/agent'
    require 'new_relic/agent/chained_call'
    require 'new_relic/agent/browser_monitoring'
    require 'new_relic/agent/agent'
    require 'new_relic/agent/shim_agent'
    require 'new_relic/agent/method_tracer'
    require 'new_relic/agent/worker_loop'
    require 'new_relic/agent/stats_engine'
    require 'new_relic/agent/transaction_sampler'
    require 'new_relic/agent/error_collector'
    require 'new_relic/agent/busy_calculator'
    require 'new_relic/agent/sampler'

    require 'new_relic/agent/instrumentation/controller_instrumentation'

    require 'new_relic/agent/samplers/cpu_sampler'
    require 'new_relic/agent/samplers/memory_sampler'
    require 'new_relic/agent/samplers/object_sampler'
    require 'new_relic/agent/samplers/delayed_job_lock_sampler'
    require 'set'
    require 'thread'
    require 'resolv'

    # An exception that is thrown by the server if the agent license is invalid.
    class LicenseException < StandardError; end

    # An exception that forces an agent to stop reporting until its mongrel is restarted.
    class ForceDisconnectException < StandardError; end

    # An exception that forces an agent to restart.
    class ForceRestartException < StandardError; end

    # Used to blow out of a periodic task without logging a an error, such as for routine
    # failures.
    class ServerConnectionException < StandardError; end

    # Used for when a transaction trace or error report has too much
    # data, so we reset the queue to clear the extra-large item
    class PostTooBigException < ServerConnectionException; end

    # Reserved for future use.  Meant to represent a problem on the server side.
    class ServerError < StandardError; end

    class BackgroundLoadingError < StandardError; end

    @agent = nil

    # The singleton Agent instance.  Used internally.
    def agent #:nodoc:
      raise "Plugin not initialized!" if @agent.nil?
      @agent
    end

    def agent=(new_instance)#:nodoc:
      @agent = new_instance
    end

    alias instance agent #:nodoc:

    # Get or create a statistics gatherer that will aggregate numerical data
    # under a metric name.
    #
    # +metric_name+ should follow a slash separated path convention. Application
    # specific metrics should begin with "Custom/".
    #
    # Return a NewRelic::Stats that accepts data
    # via calls to add_data_point(value).
    def get_stats(metric_name, use_scope=false)
      agent.stats_engine.get_stats(metric_name, use_scope)
    end

    alias get_stats_no_scope get_stats

    # Get the logger for the agent.  Available after the agent has initialized.
    # This sends output to the agent log file.
    def logger
      NewRelic::Control.instance.log
    end

    # Call this to manually start the Agent in situations where the Agent does
    # not auto-start.
    #
    # When the app environment loads, so does the Agent. However, the
    # Agent will only connect to the service if a web front-end is found. If
    # you want to selectively monitor ruby processes that don't use
    # web plugins, then call this method in your code and the Agent
    # will fire up and start reporting to the service.
    #
    # Options are passed in as overrides for values in the
    # newrelic.yml, such as app_name.  In addition, the option +log+
    # will take a logger that will be used instead of the standard
    # file logger.  The setting for the newrelic.yml section to use
    # (ie, RAILS_ENV) can be overridden with an :env argument.
    #
    def manual_start(options={})
      raise "Options must be a hash" unless Hash === options
      NewRelic::Control.instance.init_plugin({ :agent_enabled => true, :sync_startup => true }.merge(options))
    end

    # Register this method as a callback for processes that fork
    # jobs.
    #
    # If the master/parent connects to the agent prior to forking the
    # agent in the forked process will use that agent_run.  Otherwise
    # the forked process will establish a new connection with the
    # server.
    #
    # Use this especially when you fork the process to run background
    # jobs or other work.  If you are doing this with a web dispatcher
    # that forks worker processes then you will need to force the
    # agent to reconnect, which it won't do by default.  Passenger and
    # Unicorn are already handled, nothing special needed for them.
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
      agent.after_fork(options)
    end

    # Clear out any unsent metric data. See NewRelic::Agent::Agent#reset_stats
    def reset_stats
      agent.reset_stats
    end

    # Shutdown the agent.  Call this before exiting.  Sends any queued data
    # and kills the background thread.
    def shutdown(options={})
      agent.shutdown(options)
    end
    
    # a method used to serialize short-running processes to disk, so
    # we don't incur the overhead of reporting to the server for every
    # fork/invocation of a small job.
    #
    # Functionally, this loads the data from the file into the agent
    # (to avoid losing data by overwriting) and then serializes the
    # agent data to the file again. See also #load_data
    def save_data
      NewRelic::DataSerialization.read_and_write_to_file do |old_data|
        agent.merge_data_from(old_data)
        agent.serialize
      end
    end
    
    # used to load data from the disk during the harvest cycle to send
    # it. This method also clears the file so data should never be
    # sent more than once.

    # Note that only one transaction trace will be sent even if many
    # are serialized, since the slowest is sent.
    #
    # See also the complement to this method, #save_data - used when a
    # process is shutting down
    def load_data
      if !NewRelic::Control.instance['disable_serialization']
        NewRelic::DataSerialization.read_and_write_to_file do |old_data|
          agent.merge_data_from(old_data)
          nil # return nil so nothing is written to the file
        end
        NewRelic::DataSerialization.update_last_sent!
      end
      
      {
        :metrics => agent.stats_engine.metrics.length,
        :traces => agent.unsent_traces_size,
        :errors => agent.unsent_errors_size
      }
    end

    # Add instrumentation files to the agent.  The argument should be
    # a glob matching ruby scripts which will be executed at the time
    # instrumentation is loaded.  Since instrumentation is not loaded
    # when the agent is not running it's better to use this method to
    # register instrumentation than just loading the files directly,
    # although that probably also works.
    def add_instrumentation(file_pattern)
      NewRelic::Control.instance.add_instrumentation file_pattern
    end

    # This method sets the block sent to this method as a sql
    # obfuscator.  The block will be called with a single String SQL
    # statement to obfuscate.  The method must return the obfuscated
    # String SQL.  If chaining of obfuscators is required, use type =
    # :before or :after
    #
    # type = :before, :replace, :after
    #
    # Example:
    #
    #    NewRelic::Agent.set_sql_obfuscator(:replace) do |sql|
    #       my_obfuscator(sql)
    #    end
    #
    def set_sql_obfuscator(type = :replace, &block)
      agent.set_sql_obfuscator type, &block
    end


    # This method sets the state of sql recording in the transaction
    # sampler feature. Within the given block, no sql will be recorded
    #
    # usage:
    #
    #   NewRelic::Agent.disable_sql_recording do
    #     ...
    #   end
    #
    def disable_sql_recording
      state = agent.set_record_sql(false)
      begin
        yield
      ensure
        agent.set_record_sql(state)
      end
    end

    # This method disables the recording of transaction traces in the given
    # block.  See also #disable_all_tracing
    def disable_transaction_tracing
      state = agent.set_record_tt(false)
      begin
        yield
      ensure
        agent.set_record_tt(state)
      end
    end

    # Cancel the collection of the current transaction in progress, if
    # any.  Only affects the transaction started on this thread once
    # it has started and before it has completed.
    def abort_transaction!
      NewRelic::Agent::Instrumentation::MetricFrame.abort_transaction!
    end

    # Yield to the block without collecting any metrics or traces in
    # any of the subsequent calls.  If executed recursively, will keep
    # track of the first entry point and turn on tracing again after
    # leaving that block.  This uses the thread local
    # +newrelic_untrace+
    def disable_all_tracing
      agent.push_trace_execution_flag(false)
      yield
    ensure
      agent.pop_trace_execution_flag
    end

    # Check to see if we are capturing metrics currently on this thread.
    def is_execution_traced?
      Thread.current[:newrelic_untraced].nil? || Thread.current[:newrelic_untraced].last != false
    end
    
    # helper method to check the thread local to determine whether the
    # transaction in progress is traced or not
    def is_transaction_traced?
      Thread::current[:record_tt] != false
    end
    
    # helper method to check the thread local to determine whether sql
    # is being recorded or not
    def is_sql_recorded?
      Thread::current[:record_sql] != false
    end

    # Set a filter to be applied to errors that the Ruby Agent will
    # track.  The block should evalute to the exception to track
    # (which could be different from the original exception) or nil to
    # ignore this exception.
    #
    # The block is yielded to with the exception to filter.
    #
    # Return the new block or the existing filter Proc if no block is passed.
    #
    def ignore_error_filter(&block)
      agent.error_collector.ignore_error_filter(&block)
    end

    # Record the given error.  It will be passed through the
    # #ignore_error_filter if there is one.
    #
    # * <tt>exception</tt> is the exception which will be recorded.  May also be
    #   an error message.
    # Options:
    # * <tt>:uri</tt> => The request path, minus any request params or query string.
    # * <tt>:referer</tt> => The URI of the referer
    # * <tt>:metric</tt> => The metric name associated with the transaction
    # * <tt>:request_params</tt> => Request parameters, already filtered if necessary
    # * <tt>:custom_params</tt> => Custom parameters
    #
    # Anything left over is treated as custom params.
    #
    def notice_error(exception, options={})
      NewRelic::Agent::Instrumentation::MetricFrame.notice_error(exception, options)
    end

    # Add parameters to the current transaction trace (and traced error if any)
    # on the call stack.
    #
    def add_custom_parameters(params)
      NewRelic::Agent::Instrumentation::MetricFrame.add_custom_parameters(params)
    end

    # The #add_request_parameters method is aliased to #add_custom_parameters
    # and is now deprecated.
    alias add_request_parameters add_custom_parameters #:nodoc:

    # Yield to a block that is run with a database metric name
    # context.  This means the Database instrumentation will use this
    # for the metric name if it does not otherwise know about a model.
    # This is re-entrant.
    #
    # * <tt>model</tt> is the DB model class
    # * <tt>method</tt> is the name of the finder method or other
    #   method to identify the operation with.
    def with_database_metric_name(model, method, &block)
      if frame = NewRelic::Agent::Instrumentation::MetricFrame.current
        frame.with_database_metric_name(model, method, &block)
      else
        yield
      end
    end

    # Record a web transaction from an external source.  This will
    # process the response time, error, and score an apdex value.
    #
    # First argument is a float value, time in seconds.  Option
    # keys are strings.
    #
    # == Identifying the transaction
    # * <tt>'uri' => uri</tt> to record the value for a given web request.
    #   If not provided, just record the aggregate dispatcher and apdex scores.
    # * <tt>'metric' => metric_name</tt> to record with a general metric name
    #   like +OtherTransaction/Background/Class/method+.  Ignored if +uri+ is
    #   provided.
    #
    # == Error options
    # Provide one of the following:
    # * <tt>'is_error' => true</tt> if an unknown error occurred
    # * <tt>'error_message' => msg</tt> if an error message is available
    # * <tt>'exception' => exception</tt> if a ruby exception is recorded
    #
    # == Misc options
    # Additional information captured in errors
    # * <tt>'referer' => referer_url</tt>
    # * <tt>'request_params' => hash</tt> to record a set of name/value pairs as the
    #   request parameters.
    # * <tt>'custom_params' => hash</tt> to record extra information in traced errors
    #
    def record_transaction(response_sec, options = {})
      agent.record_transaction(response_sec, options)
    end

    # Returns a Javascript string which should be injected into the very top of the response body
    #
    def browser_timing_header
      agent.browser_timing_header
    end

    # Returns a Javascript string which should be injected into the very bottom of the response body
    #
    def browser_timing_footer
      agent.browser_timing_footer
    end

  end
end
