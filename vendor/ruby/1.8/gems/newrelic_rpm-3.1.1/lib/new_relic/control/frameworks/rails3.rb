require 'new_relic/control/frameworks/rails'
module NewRelic
  class Control
    module Frameworks
      # Control subclass instantiated when Rails is detected.  Contains
      # Rails 3.0+  specific configuration, instrumentation, environment values,
      # etc. Many methods are inherited from the
      # NewRelic::Control::Frameworks::Rails class, where the two do
      # not differ
      class Rails3 < NewRelic::Control::Frameworks::Rails

        def env
          ::Rails.env.to_s
        end
        
        # Rails can return an empty string from this method, causing
        # the agent not to start even when it is properly in a rails 3
        # application, so we test the value to make sure it actually
        # has contents, and bail to the parent class if it is empty.
        def root
          value = ::Rails.root.to_s
          if value.empty?
            super
          else
            value
          end
        end

        def logger
          ::Rails.logger
        end


        def log!(msg, level=:info)
          super unless should_log?
          logger.send(level, msg)
        rescue Exception => e
          super
        end

        def to_stdout(msg)
          logger.info(msg)
        rescue
          super
        end

        def vendor_root
          @vendor_root ||= File.join(root,'vendor','rails')
        end

        def version
          @rails_version ||= NewRelic::VersionNumber.new(::Rails::VERSION::STRING)
        end

        protected

        # Collect the Rails::Info into an associative array as well as the list of plugins
        def append_environment_info
          local_env.append_environment_value('Rails version'){ version }
          local_env.append_environment_value('Rails threadsafe') do
            true == ::Rails.configuration.action_controller.allow_concurrency
          end
          local_env.append_environment_value('Rails Env') { env }
          local_env.append_gem_list do
            bundler_gem_list
          end
          local_env.append_plugin_list { ::Rails.configuration.plugins.to_a }
        end
      end
    end
  end
end
