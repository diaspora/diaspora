module DeviseInvitable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Add DeviseInvitable config variables to the Devise initializer and copy DeviseInvitable locale files to your application."
      
      def add_config_options_to_initializer
        devise_initializer_path = "config/initializers/devise.rb"
        if File.exist?(devise_initializer_path)
          old_content = File.read(devise_initializer_path)
          
          if old_content.match(Regexp.new(/^\s# ==> Configuration for :invitable\n/))
            false
          else
            inject_into_file(devise_initializer_path, :before => "  # ==> Configuration for :confirmable\n") do
<<-CONTENT
  # ==> Configuration for :invitable
  # Time interval where the invitation token is valid (default: 0).
  # If invite_for is 0 or nil, the invitation will never expire.
  # config.invite_for = 2.weeks
  
CONTENT
            end
          end
        end
      end
      
      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/devise_invitable.en.yml"
      end
      
    end
  end
end
