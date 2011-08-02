module OAuth
  # The RequestToken is used for the initial Request.
  # This is normally created by the Consumer object.
  class RequestToken < ConsumerToken

    # Generate an authorization URL for user authorization
    def authorize_url(params = nil)
      params = (params || {}).merge(:oauth_token => self.token)
      build_authorize_url(consumer.authorize_url, params)
    end

    def callback_confirmed?
      params[:oauth_callback_confirmed] == "true"
    end

    # exchange for AccessToken on server
    def get_access_token(options = {}, *arguments)
      response = consumer.token_request(consumer.http_method, (consumer.access_token_url? ? consumer.access_token_url : consumer.access_token_path), self, options, *arguments)
      OAuth::AccessToken.from_hash(consumer, response)
    end

  protected

    # construct an authorization url
    def build_authorize_url(base_url, params)
      uri = URI.parse(base_url.to_s)
      # TODO doesn't handle array values correctly
      uri.query = params.map { |k,v| [k, CGI.escape(v)] * "=" } * "&"
      uri.to_s
    end
  end
end
