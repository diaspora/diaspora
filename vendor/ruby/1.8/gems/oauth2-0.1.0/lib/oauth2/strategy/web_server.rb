require 'multi_json'

module OAuth2
  module Strategy
    class WebServer < Base
      def authorize_params(options = {}) #:nodoc:
        super(options).merge('type' => 'web_server')
      end

      # Retrieve an access token given the specified validation code.
      # Note that you must also provide a <tt>:redirect_uri</tt> option
      # in order to successfully verify your request for most OAuth 2.0
      # endpoints.
      def get_access_token(code, options = {})
        response = @client.request(:post, @client.access_token_url, access_token_params(code, options))

        params   = MultiJson.decode(response) rescue nil
        # the ActiveSupport JSON parser won't cause an exception when
        # given a formencoded string, so make sure that it was
        # actually parsed in an Hash. This covers even the case where
        # it caused an exception since it'll still be nil.
        params   = Rack::Utils.parse_query(response) unless params.is_a? Hash

        access   = params['access_token']
        refresh  = params['refresh_token']
        expires_in = params['expires_in']
        OAuth2::AccessToken.new(@client, access, refresh, expires_in)
      end

      # <b>DEPRECATED:</b> Use #get_access_token instead.
      def access_token(*args)
        warn '[DEPRECATED] OAuth2::Strategy::WebServer#access_token is deprecated, use #get_access_token instead. Will be removed in 0.1.0'
        get_access_token(*args)
      end

      def access_token_params(code, options = {}) #:nodoc:
        super(options).merge({
          'type' => 'web_server',
          'code' => code
        })
      end
    end
  end
end
