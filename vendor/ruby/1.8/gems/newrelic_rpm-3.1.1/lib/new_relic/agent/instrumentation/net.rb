DependencyDetection.defer do
  depends_on do
    defined?(Net) && defined?(Net::HTTP)
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing Net instrumentation'
  end
  
  executes do
    Net::HTTP.class_eval do
      def request_with_newrelic_trace(*args, &block)
        metrics = ["External/#{@address}/Net::HTTP/#{args[0].method}","External/#{@address}/all"]
        if NewRelic::Agent::Instrumentation::MetricFrame.recording_web_transaction?
          metrics << "External/allWeb"
        else
          metrics << "External/allOther"
        end
        self.class.trace_execution_scoped metrics do
          request_without_newrelic_trace(*args, &block)
        end
      end
      alias request_without_newrelic_trace request
      alias request request_with_newrelic_trace
    end
  end
end
