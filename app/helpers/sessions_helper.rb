module SessionsHelper
  def prefilled_username
    uri = Addressable::URI.parse(session['user_return_to'])
    if uri && uri.query_values
      uri.query_values["username"]
    else
      nil
    end
  end

  def should_display_registration_link?
    !AppConfig[:registrations_closed] && devise_mapping.registerable? && controller_name != 'registrations'
  end
end
