module Devise
  module Controllers
    # Create url helpers to be used with resource/scope configuration. Acts as
    # proxies to the generated routes created by devise.
    # Resource param can be a string or symbol, a class, or an instance object.
    # Example using a :user resource:
    #
    #   new_session_path(:user)      => new_user_session_path
    #   session_path(:user)          => user_session_path
    #   destroy_session_path(:user)  => destroy_user_session_path
    #
    #   new_password_path(:user)     => new_user_password_path
    #   password_path(:user)         => user_password_path
    #   edit_password_path(:user)    => edit_user_password_path
    #
    #   new_confirmation_path(:user) => new_user_confirmation_path
    #   confirmation_path(:user)     => user_confirmation_path
    #
    # Those helpers are added to your ApplicationController.
    module UrlHelpers

      Devise::URL_HELPERS.each do |module_name, actions|
        [:path, :url].each do |path_or_url|
          actions.each do |action|
            action = action ? "#{action}_" : ""

            class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
              def #{action}#{module_name}_#{path_or_url}(resource_or_scope, *args)
                scope = Devise::Mapping.find_scope!(resource_or_scope)
                send("#{action}\#{scope}_#{module_name}_#{path_or_url}", *args)
              end
            URL_HELPERS
          end
        end
      end

    end
  end
end
