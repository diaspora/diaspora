module DeviseInvitable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Add DeviseInvitable config variables to the Devise initializer and copy DeviseInvitable locale files to your application."
      
      # def devise_install
      #   invoke "devise:install"
      # end
      
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
  # The period the generated invitation token is valid, after
  # this period, the invited resource won't be able to accept the invitation.
  # When invite_for is 0 (the default), the invitation won't expire.
  # config.invite_for = 2.weeks
  
  # Number of invitations users can send.
  # If invitation_limit is nil, users can send unlimited invitations.
  # If invitation_limit is 0, users can't send invitations.
  # If invitation_limit n > 0, users can send n invitations.
  # Default: nil
  # config.invitation_limit = 5
  
  # The key to be used to check existing users when sending an invitation
  # config.invite_key = :email
  
  # Flag that force a record to be valid before being actually invited 
  # Default: false
  # config.validate_on_invite = true

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
