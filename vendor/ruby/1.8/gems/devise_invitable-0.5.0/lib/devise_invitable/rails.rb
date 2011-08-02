module DeviseInvitable
  class Engine < ::Rails::Engine
    
    ActiveSupport.on_load(:action_controller) { include DeviseInvitable::Controllers::UrlHelpers }
    ActiveSupport.on_load(:action_view)       { include DeviseInvitable::Controllers::UrlHelpers }
    
    # We use to_prepare instead of after_initialize here because Devise is a Rails engine; its
    # mailer is reloaded like the rest of the user's app.  Got to make sure that our mailer methods
    # are included each time Devise::Mailer is (re)loaded.
    config.to_prepare do
      require 'devise/mailer'
      Devise::Mailer.send :include, DeviseInvitable::Mailer
    end
    
  end
end
