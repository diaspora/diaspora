module Authenticator
  def send_error_to_app(callback_url, error_code)
    Workers::PostToApp.perform_async(callback_url, {:error => error_code})
  end

  def send_refresh_token_to_app(callback_url, refresh_token, diaspora_handle)
    Workers::PostToApp.perform_async(callback_url, {:refresh_token => refresh_token, :diaspora_handle => diaspora_handle})
  end
end