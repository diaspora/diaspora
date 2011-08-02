module NewRelic
  class Control
    # class-level methods for lazy creation of NewRelic::Control and
    # NewRelic::LocalEnvironment instances.
    module ClassMethods
      # Access the Control singleton, lazy initialized
      def instance
        @instance ||= new_instance
      end
      
      # Access the LocalEnvironment singleton, lazy initialized
      def local_env
        @local_env ||= NewRelic::LocalEnvironment.new
      end

      # Create the concrete class for environment specific behavior
      def new_instance
        if local_env.framework == :test
          load_test_framework
        else
          load_framework_class(local_env.framework).new(local_env)
        end
      end

      # nb this does not 'load test' the framework, it loads the 'test framework'
      def load_test_framework
        config = File.expand_path(File.join('..','..','..','..', "test","config","newrelic.yml"), __FILE__)
        require "config/test_control"
        NewRelic::Control::Frameworks::Test.new(local_env, config)
      end
      
      # Loads the specified framework class from the
      # NewRelic::Control::Frameworks module
      def load_framework_class(framework)
        begin
          require "new_relic/control/frameworks/#{framework}"
        rescue LoadError
          # maybe it is already loaded by some external system
          # i.e. rpm_contrib or user extensions?
        end
        NewRelic::Control::Frameworks.const_get(framework.to_s.capitalize)
      end

      # The root directory for the plugin or gem
      def newrelic_root
        File.expand_path(File.join("..", "..", "..", ".."), __FILE__)
      end
    end
    extend ClassMethods
  end
end

