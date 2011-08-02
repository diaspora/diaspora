require 'new_relic/agent/instrumentation/controller_instrumentation'

module NewRelic
  module Agent
    module Instrumentation
      # == Instrumentation for Rack
      #
      # New Relic will instrument a #call method as if it were a controller
      # action, collecting transaction traces and errors.  The middleware will
      # be identified only by it's class, so if you want to instrument multiple
      # actions in a middleware, you need to use
      # NewRelic::Agent::Instrumentation::ControllerInstrumentation::ClassMethods#add_transaction_tracer
      #
      # Example:
      #   require 'newrelic_rpm'
      #   require 'new_relic/agent/instrumentation/rack'
      #   class Middleware
      #     def call(env)
      #       ...
      #     end
      #     # Do the include after the call method is defined:
      #     include NewRelic::Agent::Instrumentation::Rack
      #   end
      #
      # == Instrumenting Metal and Cascading Middlewares
      #
      # Metal apps and apps belonging to Rack::Cascade middleware
      # follow a convention of returning a 404 for all requests except
      # the ones they are set up to handle.  This means that New Relic
      # needs to ignore these calls when they return a 404.
      #
      # In these cases, you should not include or extend the Rack
      # module but instead include
      # NewRelic::Agent::Instrumentation::ControllerInstrumentation.
      # Here's how that might look for a Metal app:
      #
      #   require 'new_relic/agent/instrumentation/controller_instrumentation'
      #   class MetalApp
      #     extend NewRelic::Agent::Instrumentation::ControllerInstrumentation
      #     def self.call(env)
      #       if should_do_my_thing?
      #         perform_action_with_newrelic_trace(:category => :rack) do
      #           return my_response(env)
      #         end
      #       else
      #         return [404, {"Content-Type" => "text/html"}, ["Not Found"]]
      #       end
      #     end
      #   end
      #
      # == Overriding the metric name
      #
      # By default the middleware is identified only by its class, but if you want to
      # be more specific and pass in name, then omit including the Rack instrumentation
      # and instead follow this example:
      #
      #   require 'newrelic_rpm'
      #   require 'new_relic/agent/instrumentation/controller_instrumentation'
      #   class Middleware
      #     include NewRelic::Agent::Instrumentation::ControllerInstrumentation
      #     def call(env)
      #       ...
      #     end
      #     add_transaction_tracer :call, :category => :rack, :name => 'my app'
      #   end
      #
      module Rack
        def newrelic_request_headers
          @newrelic_request.env
        end
        def call_with_newrelic(*args)
          @newrelic_request = ::Rack::Request.new(args.first)
          perform_action_with_newrelic_trace(:category => :rack, :request => @newrelic_request) do
            result = call_without_newrelic(*args)
            # Ignore cascaded calls
            MetricFrame.abort_transaction! if result.first == 404
            result
          end
        end
        def self.included middleware #:nodoc:
          middleware.class_eval do
            alias call_without_newrelic call
            alias call call_with_newrelic
          end
        end
        include ControllerInstrumentation
        def self.extended middleware #:nodoc:
          middleware.class_eval do
            class << self
              alias call_without_newrelic call
              alias call call_with_newrelic
            end
          end
        end
      end
    end
  end
end
