DependencyDetection.defer do
  depends_on do
    defined?(ActiveMerchant)
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing ActiveMerchant instrumentation'
  end
  
  executes do
    ActiveMerchant::Billing::Gateway.implementations.each do |gateway|
      gateway.class_eval do
        implemented_methods = public_instance_methods(false)
        gateway_name = self.name.split('::').last
        [:authorize, :purchase, :credit, :void, :capture, :recurring].each do |operation|
          if implemented_methods.include?(operation.to_s)
            add_method_tracer operation, "ActiveMerchant/gateway/#{gateway_name}/#{operation}", :scoped_metric_only => true
            add_method_tracer operation, "ActiveMerchant/gateway/#{gateway_name}", :push_scope => false
            add_method_tracer operation, "ActiveMerchant/operation/#{operation}", :push_scope => false
          end
        end
      end
    end
  end
end
