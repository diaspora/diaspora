require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  depends_on do
    defined?(::Sinatra) && defined?(::Sinatra::Base)
  end

  executes do
    NewRelic::Agent.logger.debug 'Installing Sinatra instrumentation'
  end

  executes do
    ::Sinatra::Base.class_eval do
      include NewRelic::Agent::Instrumentation::Sinatra
      alias route_eval_without_newrelic route_eval
      alias route_eval route_eval_with_newrelic
    end
  end
end


module NewRelic
  module Agent
    module Instrumentation
      # NewRelic instrumentation for Sinatra applications.  Sinatra actions will
      # appear in the UI similar to controller actions, and have breakdown charts
      # and transaction traces.
      #
      # The actions in the UI will correspond to the pattern expression used
      # to match them.  HTTP operations are not distinguished.  Multiple matches
      # will all be tracked as separate actions.
      module Sinatra

        include NewRelic::Agent::Instrumentation::ControllerInstrumentation

        def route_eval_with_newrelic(&block_arg)
          path = unescape(@request.path_info)
          name = path
          # Go through each route and look for a match
          if routes = self.class.routes[@request.request_method]
            routes.detect do |pattern, keys, conditions, block|
              if block_arg.equal? block
                name = pattern.source
              end
            end
          end
          # strip off leading ^ and / chars and trailing $ and /
          name.gsub!(%r{^[/^]*(.*?)[/\$\?]*$}, '\1')
          name = 'root' if name.empty?
          name = @request.request_method + ' ' + name if @request && @request.respond_to?(:request_method)
          perform_action_with_newrelic_trace(:category => :sinatra, :name => name, :params => @request.params) do
            route_eval_without_newrelic(&block_arg)
          end
        end
      end
    end
  end
end
