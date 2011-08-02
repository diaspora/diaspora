module NewRelic
  class Control
    module Frameworks
      # Includes limited support for Merb
      class Merb < NewRelic::Control

        def env
          @env ||= ::Merb.env
        end
        def root
          ::Merb.root
        end

        def to_stdout(msg)
          Merb.logger.info("NewRelic ~ " + msg)
        rescue Exception => e
          STDOUT.puts "NewRelic ~ " + msg
        end

        def init_config options={}
          ::Merb::Plugins.add_rakefiles File.join(newrelic_root,"lib/tasks/all.rb")

          # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
          ::Merb::Plugins.config[:newrelic] = {
            :config => self
          }
        end
      end
    end
  end
end
