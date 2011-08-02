require 'dependency_detection'
# This installs some code to manually start the agent when a delayed
# job worker starts.  It's not really instrumentation.  It's more like
# a hook from DJ to the Ruby Agent so it gets loaded at the time the
# Ruby Agent initializes, which must be before the DJ worker
# initializes.  Loaded from control.rb
module NewRelic
  module DelayedJobInjection
    extend self
    attr_accessor :worker_name
  end
end

DependencyDetection.defer do
  depends_on do
    defined?(::Delayed) && defined?(::Delayed::Worker)
  end
  
  executes do
    if NewRelic::Agent.respond_to?(:logger)
      NewRelic::Agent.logger.debug 'Installing DelayedJob instrumentation hooks'
    end
  end
  
  executes do
    Delayed::Worker.class_eval do
      def initialize_with_new_relic(*args)
        initialize_without_new_relic(*args)
        worker_name = case
                      when self.respond_to?(:name) then self.name
                      when self.class.respond_to?(:default_name) then self.class.default_name
                      end
        dispatcher_instance_id = worker_name || "host:#{Socket.gethostname} pid:#{Process.pid}" rescue "pid:#{Process.pid}"
        say "New Relic Ruby Agent Monitoring DJ worker #{dispatcher_instance_id}"
        NewRelic::DelayedJobInjection.worker_name = worker_name
        NewRelic::Control.instance.init_plugin :dispatcher => :delayed_job, :dispatcher_instance_id => dispatcher_instance_id
      end

      alias initialize_without_new_relic initialize
      alias initialize initialize_with_new_relic
    end
  end
end
DependencyDetection.detect!
