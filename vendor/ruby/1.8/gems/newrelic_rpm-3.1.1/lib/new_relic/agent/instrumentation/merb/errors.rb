DependencyDetection.defer do
  depends_on do
    defined?(Merb) && defined?(Merb::Dispatcher) && defined?(Merb::Dispatcher::DefaultException)
  end

  depends_on do
    Merb::Dispatcher::DefaultException.respond_to?(:before)
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing Merb Errors instrumentation'
  end
  
  executes do

    # Hook in the notification to merb
    error_notifier = Proc.new {
      if request.exceptions #check that there's actually an exception
        # Note, this assumes we have already captured the other information such as uri and params in the MetricFrame.
        NewRelic::Agent::Instrumentation::MetricFrame.notice_error(request.exceptions.first)
      end
    }
    Merb::Dispatcher::DefaultException.before error_notifier
    Exceptions.before error_notifier

  end
end
