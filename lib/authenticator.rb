module Authenticator
  def send_error_to_app(callback_url, error_code)
    Workers::PostToApp.perform_async(callback_url, {:error => error_code})
  end
end