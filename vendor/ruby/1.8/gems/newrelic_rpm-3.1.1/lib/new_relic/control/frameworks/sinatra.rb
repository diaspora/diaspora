
require 'new_relic/control/frameworks/ruby'
module NewRelic
  class Control
    module Frameworks
      # Contains basic control logic for Sinatra
      class Sinatra < NewRelic::Control::Frameworks::Ruby

        def env
          @env ||= ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
        end

        def init_config(options={})
          super
        end

      end
    end
  end
end
