module SessionsHelper
  def prefilled_username
    uri = Addressable::URI.parse(session['user_return_to'])
    if uri && uri.query_values
      uri.query_values["username"]
    else
      nil
    end
  end

  def display_registration_link?
    AppConfig.settings.enable_registrations? && devise_mapping.registerable? && controller_name != 'registrations'
  end

  def display_password_reset_link?
    devise_mapping.recoverable? && controller_name != 'passwords'
  end
end
