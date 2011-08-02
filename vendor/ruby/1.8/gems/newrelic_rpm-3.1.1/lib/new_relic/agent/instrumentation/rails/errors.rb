DependencyDetection.defer do
  depends_on do
    defined?(ActionController) && defined?(ActionController::Base)
  end

  depends_on do
    defined?(Rails) && Rails::VERSION::MAJOR.to_i == 2
  end

  executes do
    NewRelic::Agent.logger.debug 'Installing Rails Error instrumentation'
  end  
  
  executes do

    ActionController::Base.class_eval do

      # Make a note of an exception associated with the currently executing
      # controller action.  Note that this used to be available on Object
      # but we replaced that global method with NewRelic::Agent#notice_error.
      # Use that one outside of controller actions.
      def newrelic_notice_error(exception, custom_params = {})
        NewRelic::Agent::Instrumentation::MetricFrame.notice_error exception, :custom_params => custom_params, :request => request
      end

      def rescue_action_with_newrelic_trace(exception)
        rescue_action_without_newrelic_trace exception
        NewRelic::Agent::Instrumentation::MetricFrame.notice_error exception, :request => request
      end

      # Compare with #alias_method_chain, which is not available in
      # Rails 1.1:
      alias_method :rescue_action_without_newrelic_trace, :rescue_action
      alias_method :rescue_action, :rescue_action_with_newrelic_trace
      protected :rescue_action

    end
  end
end

