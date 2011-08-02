DependencyDetection.defer do
  depends_on do
    defined?(AuthLogic) &&
      defined?(AuthLogic::Session) &&
      defined?(AuthLogic::Session::Base)
  end

  executes do
    NewRelic::Agent.logger.debug 'Installing AuthLogic instrumentation'
  end  
  
  executes do
    AuthLogic::Session::Base.class_eval do
      add_method_tracer :find, 'Custom/Authlogic/find'
    end
  end
end
