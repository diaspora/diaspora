module NewRelic
  module Agent
    module Instrumentation
      module Rails3
        module Errors
          def newrelic_notice_error(exception, custom_params = {})
            filtered_params = (respond_to? :filter_parameters) ? filter_parameters(params) : params
            filtered_params.merge!(custom_params)
            NewRelic::Agent.agent.error_collector.notice_error(exception, request, newrelic_metric_path, filtered_params)
          end
        end
      end
    end
  end
end

DependencyDetection.defer do
  depends_on do
    defined?(Rails) && Rails.respond_to?(:version) && Rails.version.to_i == 3
  end

  depends_on do
    defined?(ActionController) && defined?(ActionController::Base)
  end

  executes do
    NewRelic::Agent.logger.debug 'Installing Rails3 Error instrumentation'
  end

  executes do
    class ActionController::Base
      include NewRelic::Agent::Instrumentation::Rails3::Errors
    end
  end
end
