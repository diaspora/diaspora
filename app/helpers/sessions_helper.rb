module SessionsHelper
  def prefilled_username
    uri = Addressable::URI.parse(session['user_return_to'])
    if uri && uri.query_values
      uri.query_values["username"]
    else
      nil
    end
  end
end
