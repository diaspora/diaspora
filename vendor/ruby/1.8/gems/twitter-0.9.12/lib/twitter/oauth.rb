module Twitter
  class OAuth
    extend Forwardable

    def_delegators :access_token, :get, :post, :put, :delete

    attr_reader :ctoken, :csecret, :consumer_options, :api_endpoint, :signing_endpoint

    # Options
    #   :sign_in => true to just sign in with twitter instead of doing oauth authorization
    #               (http://apiwiki.twitter.com/Sign-in-with-Twitter)
    def initialize(ctoken, csecret, options={})
      @ctoken, @csecret, @consumer_options = ctoken, csecret, {}
      @api_endpoint = options[:api_endpoint] || 'http://api.twitter.com'
      @signing_endpoint = options[:signing_endpoint] || 'http://api.twitter.com'
      if options[:sign_in]
        @consumer_options[:authorize_path] =  '/oauth/authenticate'
      end
    end

    def consumer
      @consumer ||= ::OAuth::Consumer.new(@ctoken, @csecret, {:site => api_endpoint}.merge(consumer_options))
    end

    def signing_consumer
      @signing_consumer ||= ::OAuth::Consumer.new(@ctoken, @csecret, {:site => signing_endpoint, :request_endpoint => api_endpoint }.merge(consumer_options))
    end

    def set_callback_url(url)
      clear_request_token
      request_token(:oauth_callback => url)
    end

    # Note: If using oauth with a web app, be sure to provide :oauth_callback.
    # Options:
    #   :oauth_callback => String, url that twitter should redirect to
    def request_token(options={})
      @request_token ||= signing_consumer.get_request_token(options)
    end

    # For web apps use params[:oauth_verifier], for desktop apps,
    # use the verifier is the pin that twitter gives users.
    def authorize_from_request(rtoken, rsecret, verifier_or_pin)
      request_token = ::OAuth::RequestToken.new(signing_consumer, rtoken, rsecret)
      access_token = request_token.get_access_token(:oauth_verifier => verifier_or_pin)
      @atoken, @asecret = access_token.token, access_token.secret
    end

    def access_token
      @access_token ||= ::OAuth::AccessToken.new(signing_consumer, @atoken, @asecret)
    end

    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end

    private

    def clear_request_token
      @request_token = nil
    end

  end
end
