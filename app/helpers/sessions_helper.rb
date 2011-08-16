module SessionsHelper
  def prefilled_username
    uri = Addressable::URI.parse(session["user_return_to"])
    uri ? uri.query_values["uid"] : nil
  end
end
