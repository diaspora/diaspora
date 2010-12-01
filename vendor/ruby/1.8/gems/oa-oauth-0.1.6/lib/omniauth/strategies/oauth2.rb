require 'cgi'
require 'uri'
require 'oauth2'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    # Authentication strategy for connecting with APIs constructed using
    # the [OAuth 2.0 Specification](http://tools.ietf.org/html/draft-ietf-oauth-v2-10).
    # You must generally register your application with the provider and
    # utilize an application id and secret in order to authenticate using
    # OAuth 2.0.
    class OAuth2
      include OmniAuth::Strategy
      
      # The options passed in to the strategy.
      attr_accessor :options
      # The `OAuth2::Client` for this strategy.
      attr_accessor :client
      
      # An error that is indicated in the OAuth 2.0 callback.
      # This could be a `redirect_uri_mismatch` or other 
      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri
        
        def initialize(error, error_reason=nil, error_uri=nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end
      end
      
      # Initialize a new OAuth 2.0 authentication provider.
      
      # @param [Rack Application] app standard middleware application argument
      # @param [String] name the name for this provider to be used in its URL, e.g. `/auth/name`
      # @param [String] client_id the client/application ID of this provider
      # @param [String] client_secret the client/application secret of this provider
      # @param [Hash] options that will be passed through to the OAuth2::Client (see [oauth2 docs](http://rubydoc.info/gems/oauth2))
      def initialize(app, name, client_id, client_secret, options = {})
        super(app, name)
        self.options = options
        self.client = ::OAuth2::Client.new(client_id, client_secret, options)
      end
      
      protected
        
      def request_phase
        redirect client.web_server.authorize_url({:redirect_uri => callback_url}.merge(options))
      end
      
      def callback_phase
        if request.params['error'] || request.params['error_reason']
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        end
        
        verifier = request.params['code']
        @access_token = client.web_server.get_access_token(verifier, :redirect_uri => callback_url)
        super
      rescue ::OAuth2::HTTPError, ::OAuth2::AccessDenied, CallbackError => e
        fail!(:invalid_credentials, e)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'credentials' => {
            'token' => @access_token.token
          }
        })
      end
    end
  end
end
