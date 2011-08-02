require 'new_relic/agent/instrumentation/metric_frame'
require 'new_relic/agent/instrumentation/queue_time'
module NewRelic
  module Agent
    module Instrumentation
      # == NewRelic instrumentation for controller actions and tasks
      #
      # This instrumentation is applied to the action controller to collect
      # metrics for every web request.
      #
      # It can also be used to capture performance information for
      # background tasks and other non-web transactions, including
      # detailed transaction traces and traced errors.
      #
      # For details on how to instrument background tasks see
      # ClassMethods#add_transaction_tracer and
      # #perform_action_with_newrelic_trace
      #
      module ControllerInstrumentation

        def self.included(clazz) # :nodoc:
          clazz.extend(ClassMethods)
        end

        # This module is for importing stubs when the agent is disabled
        module ClassMethodsShim # :nodoc:
          def newrelic_ignore(*args); end
          def newrelic_ignore_apdex(*args); end
        end

        module Shim # :nodoc:
          def self.included(clazz)
            clazz.extend(ClassMethodsShim)
          end
          def newrelic_notice_error(*args); end
          def new_relic_trace_controller_action(*args); yield; end
          def newrelic_metric_path; end
          def perform_action_with_newrelic_trace(*args); yield; end
        end

        module ClassMethods
          # Have NewRelic ignore actions in this controller.  Specify the actions as hash options
          # using :except and :only.  If no actions are specified, all actions are ignored.
          def newrelic_ignore(specifiers={})
            newrelic_ignore_aspect('do_not_trace', specifiers)
          end
          # Have NewRelic omit apdex measurements on the given actions.  Typically used for
          # actions that are not user facing or that skew your overall apdex measurement.
          # Accepts :except and :only options, as with #newrelic_ignore.
          def newrelic_ignore_apdex(specifiers={})
            newrelic_ignore_aspect('ignore_apdex', specifiers)
          end

          def newrelic_ignore_aspect(property, specifiers={}) # :nodoc:
            if specifiers.empty?
              self.newrelic_write_attr property, true
            elsif ! (Hash === specifiers)
              logger.error "newrelic_#{property} takes an optional hash with :only and :except lists of actions (illegal argument type '#{specifiers.class}')"
            else
              self.newrelic_write_attr property, specifiers
            end
          end

          # Should be monkey patched into the controller class implemented
          # with the inheritable attribute mechanism.
          def newrelic_write_attr(attr_name, value) # :nodoc:
            instance_variable_set "@#{attr_name}", value
          end
          def newrelic_read_attr(attr_name) # :nodoc:
            instance_variable_get "@#{attr_name}"
          end

          # Add transaction tracing to the given method.  This will treat
          # the given method as a main entrypoint for instrumentation, just
          # like controller actions are treated by default.  Useful especially
          # for background tasks.
          #
          # Example for background job:
          #   class Job
          #     include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          #     def run(task)
          #        ...
          #     end
          #     # Instrument run so tasks show up under task.name.  Note single
          #     # quoting to defer eval to runtime.
          #     add_transaction_tracer :run, :name => '#{args[0].name}'
          #   end
          #
          # Here's an example of a controller that uses a dispatcher
          # action to invoke operations which you want treated as top
          # level actions, so they aren't all lumped into the invoker
          # action.
          #
          #   MyController < ActionController::Base
          #     include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          #     # dispatch the given op to the method given by the service parameter.
          #     def invoke_operation
          #       op = params['operation']
          #       send op
          #     end
          #     # Ignore the invoker to avoid double counting
          #     newrelic_ignore :only => 'invoke_operation'
          #     # Instrument the operations:
          #     add_transaction_tracer :print
          #     add_transaction_tracer :show
          #     add_transaction_tracer :forward
          #   end
          #
          # Here's an example of how to pass contextual information into the transaction
          # so it will appear in transaction traces:
          #
          #   class Job
          #     include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          #     def process(account)
          #        ...
          #     end
          #     # Include the account name in the transaction details.  Note the single
          #     # quotes to defer eval until call time.
          #     add_transaction_tracer :process, :params => '{ :account_name => args[0].name }'
          #   end
          #
          # See NewRelic::Agent::Instrumentation::ControllerInstrumentation#perform_action_with_newrelic_trace
          # for the full list of available options.
          #
          def add_transaction_tracer(method, options={})
            # The metric path:
            options[:name] ||= method.to_s
            # create the argument list:
            options_arg = []
            options.each do |key, value|
              valuestr = case
                         when value.is_a?(Symbol)
                           value.inspect
                         when key == :params
                           value.to_s
                         else
                           %Q["#{value.to_s}"]
                         end
              options_arg << %Q[:#{key} => #{valuestr}]
            end
            class_eval <<-EOC
              def #{method.to_s}_with_newrelic_transaction_trace(*args, &block)
                perform_action_with_newrelic_trace(#{options_arg.join(',')}) do
                  #{method.to_s}_without_newrelic_transaction_trace(*args, &block)
                 end
              end
            EOC
            alias_method "#{method.to_s}_without_newrelic_transaction_trace", method.to_s
            alias_method method.to_s, "#{method.to_s}_with_newrelic_transaction_trace"
            NewRelic::Control.instance.log.debug("Traced transaction: class = #{self.name}, method = #{method.to_s}, options = #{options.inspect}")
          end
        end

        # Must be implemented in the controller class:
        # Determine the path that is used in the metric name for
        # the called controller action.  Of the form controller_path/action_name
        #
        def newrelic_metric_path(action_name_override = nil) # :nodoc:
          raise "Not implemented!"
        end

        # Yield to the given block with NewRelic tracing.  Used by
        # default instrumentation on controller actions in Rails and Merb.
        # But it can also be used in custom instrumentation of controller
        # methods and background tasks.
        #
        # This is the method invoked by instrumentation added by the
        # <tt>ClassMethods#add_transaction_tracer</tt>.
        #
        # Here's a more verbose version of the example shown in
        # <tt>ClassMethods#add_transaction_tracer</tt> using this method instead of
        # #add_transaction_tracer.
        #
        # Below is a controller with an +invoke_operation+ action which
        # dispatches to more specific operation methods based on a
        # parameter (very dangerous, btw!).  With this instrumentation,
        # the +invoke_operation+ action is ignored but the operation
        # methods show up in New Relic as if they were first class controller
        # actions
        #
        #   MyController < ActionController::Base
        #     include NewRelic::Agent::Instrumentation::ControllerInstrumentation
        #     # dispatch the given op to the method given by the service parameter.
        #     def invoke_operation
        #       op = params['operation']
        #       perform_action_with_newrelic_trace(:name => op) do
        #         send op, params['message']
        #       end
        #     end
        #     # Ignore the invoker to avoid double counting
        #     newrelic_ignore :only => 'invoke_operation'
        #   end
        #
        #
        # When invoking this method explicitly as in the example above, pass in a
        # block to measure with some combination of options:
        #
        # * <tt>:category => :controller</tt> indicates that this is a
        #   controller action and will appear with all the other actions.  This
        #   is the default.
        # * <tt>:category => :task</tt> indicates that this is a
        #   background task and will show up in New Relic with other background
        #   tasks instead of in the controllers list
        # * <tt>:category => :rack</tt> if you are instrumenting a rack
        #   middleware call.  The <tt>:name</tt> is optional, useful if you
        #   have more than one potential transaction in the #call.
        # * <tt>:category => :uri</tt> indicates that this is a
        #   web transaction whose name is a normalized URI, where  'normalized'
        #   means the URI does not have any elements with data in them such
        #   as in many REST URIs.
        # * <tt>:name => action_name</tt> is used to specify the action
        #   name used as part of the metric name
        # * <tt>:params => {...}</tt> to provide information about the context
        #   of the call, used in transaction trace display, for example:
        #   <tt>:params => { :account => @account.name, :file => file.name }</tt>
        #   These are treated similarly to request parameters in web transactions.
        #
        # Seldomly used options:
        #
        # * <tt>:force => true</tt> indicates you should capture all
        #   metrics even if the #newrelic_ignore directive was specified
        # * <tt>:class_name => aClass.name</tt> is used to override the name
        #   of the class when used inside the metric name.  Default is the
        #   current class.
        # * <tt>:path => metric_path</tt> is *deprecated* in the public API.  It
        #   allows you to set the entire metric after the category part.  Overrides
        #   all the other options.
        # * <tt>:request => Rack::Request#new(env)</tt> is used to pass in a
        #   request object that may respond to uri and referer.
        #
        # If a single argument is passed in, it is treated as a metric
        # path.  This form is deprecated.
        def perform_action_with_newrelic_trace(*args, &block)

          # Skip instrumentation based on the value of 'do_not_trace' and if
          # we aren't calling directly with a block.
          if !block_given? && do_not_trace?
            # Also ignore all instrumentation in the call sequence
            NewRelic::Agent.disable_all_tracing do
              return perform_action_without_newrelic_trace(*args)
            end
          end

          return perform_action_with_newrelic_profile(args, &block) if NewRelic::Control.instance.profiling?

          frame_data = _push_metric_frame(block_given? ? args : [])
          begin
            NewRelic::Agent.trace_execution_scoped frame_data.recorded_metrics, :force => frame_data.force_flag do
              frame_data.start_transaction
              begin
                NewRelic::Agent::BusyCalculator.dispatcher_start frame_data.start
                if block_given?
                  yield
                else
                  perform_action_without_newrelic_trace(*args)
                end
              rescue Exception => e
                frame_data.notice_error(e)
                raise
              end
            end
          ensure
            NewRelic::Agent::BusyCalculator.dispatcher_finish
            # Look for a metric frame in the thread local and process it.
            # Clear the thread local when finished to ensure it only gets called once.
            frame_data.record_apdex unless ignore_apdex?

            frame_data.pop
          end
        end

        protected
        # Should be implemented in the dispatcher class
        def newrelic_response_code; end

        def newrelic_request_headers
          self.respond_to?(:request) && self.request.respond_to?(:headers) && self.request.headers
        end
        
        # overrideable method to determine whether to trace an action
        # or not - you may override this in your controller and supply
        # your own logic for ignoring transactions.
        def do_not_trace?
          _is_filtered?('do_not_trace')
        end
        
        # overrideable method to determine whether to trace an action
        # for purposes of apdex measurement - you can use this to
        # ignore things like api calls or other fast non-user-facing
        # actions
        def ignore_apdex?
          _is_filtered?('ignore_apdex')
        end

        private

        # Profile the instrumented call.  Dev mode only.  Experimental
        # - should definitely not be used on production applications
        def perform_action_with_newrelic_profile(args)
          frame_data = _push_metric_frame(block_given? ? args : [])
          val = nil
          NewRelic::Agent.trace_execution_scoped frame_data.metric_name do
            MetricFrame.current(true).start_transaction
            NewRelic::Agent.disable_all_tracing do
              # turn on profiling
              profile = RubyProf.profile do
                if block_given?
                  val = yield
                else
                  val = perform_action_without_newrelic_trace(*args)
                end
              end
              NewRelic::Agent.instance.transaction_sampler.notice_profile profile
            end
          end
          return val
        ensure
          frame_data.pop
        end

        # Write a metric frame onto a thread local if there isn't already one there.
        # If there is one, just update it.
        def _push_metric_frame(args) # :nodoc:
          frame_data = NewRelic::Agent::Instrumentation::MetricFrame.current(true)

          frame_data.apdex_start ||= _detect_upstream_wait(frame_data.start)
          _record_queue_length
          # If a block was passed in, then the arguments represent options for the instrumentation,
          # not app method arguments.
          if args.any?
            if args.last.is_a?(Hash)
              options = args.last
              frame_data.force_flag = options[:force]
              frame_data.request = options[:request] if options[:request]
            end
            category, path, available_params = _convert_args_to_path(args)
          else
            category = 'Controller'
            path = newrelic_metric_path
            available_params = self.respond_to?(:params) ? self.params : {}
          end
          frame_data.request ||= self.request if self.respond_to? :request
          frame_data.push(category + '/'+ path)
          frame_data.filtered_params = (respond_to? :filter_parameters) ? filter_parameters(available_params) : available_params
          frame_data
        end

        def _convert_args_to_path(args)
          options =  args.last.is_a?(Hash) ? args.pop : {}
          params = options[:params] || {}
          category = case options[:category]
                     when :controller, nil then 'Controller'
                     when :task then 'OtherTransaction/Background' # 'Task'
                     when :rack then 'Controller/Rack' #'WebTransaction/Rack'
                     when :uri then 'Controller' #'WebTransaction/Uri'
                     when :sinatra then 'Controller/Sinatra' #'WebTransaction/Uri'
                       # for internal use only
                     else options[:category].to_s
                     end
          unless path = options[:path]
            action = options[:name] || args.first
            metric_class = options[:class_name] || (self.is_a?(Class) ? self.name : self.class.name)
            path = metric_class
            path += ('/' + action) if action
          end
          [category, path, params]
        end

        # Filter out a request if it matches one of our parameters for
        # ignoring it - the key is either 'do_not_trace' or 'ignore_apdex'
        def _is_filtered?(key)
          ignore_actions = self.class.newrelic_read_attr(key) if self.class.respond_to? :newrelic_read_attr
          case ignore_actions
          when nil; false
          when Hash
            only_actions = Array(ignore_actions[:only])
            except_actions = Array(ignore_actions[:except])
            only_actions.include?(action_name.to_sym) || (except_actions.any? && !except_actions.include?(action_name.to_sym))
          else
            true
          end
        end
        # Take a guess at a measure representing the number of requests waiting in mongrel
        # or heroku.
        def _record_queue_length
          if newrelic_request_headers
            if queue_depth = newrelic_request_headers['HTTP_X_HEROKU_QUEUE_DEPTH']
              queue_depth = queue_depth.to_i rescue nil
            elsif mongrel = NewRelic::Control.instance.local_env.mongrel
              # Always subtrace 1 for the active mongrel
              queue_depth = [mongrel.workers.list.length.to_i - 1, 0].max rescue nil
            end
            NewRelic::Agent.agent.stats_engine.get_stats_no_scope('Mongrel/Queue Length').trace_call(queue_depth) if queue_depth
          end
        end

        include NewRelic::Agent::Instrumentation::QueueTime

        # Return a Time instance representing the upstream start time.
        # now is a Time instance to fall back on if no other candidate
        # for the start time is found.
        def _detect_upstream_wait(now)
          queue_start = nil
          if newrelic_request_headers
            queue_start = parse_frontend_headers(newrelic_request_headers)
            Thread.current[:newrelic_queue_time] = (now.to_f - queue_start.to_f) if queue_start
          end
          queue_start || now
        rescue Exception => e
          NewRelic::Control.instance.log.error("Error detecting upstream wait time: #{e}")
          NewRelic::Control.instance.log.debug("#{e.backtrace[0..20]}")
          now
        end
        
        # returns the NewRelic::MethodTraceStats object associated
        # with the dispatcher time measurement
        def _dispatch_stat
          NewRelic::Agent.agent.stats_engine.get_stats_no_scope 'HttpDispatcher'
        end

      end
    end
  end
end
