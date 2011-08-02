require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Bitly utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Bitly, 'API Key', 'Secret Key'
    class Bitly < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] api_key the application id as [registered on Bitly](http://bit.ly/a/account)
      # @param [String] secret_key the application secret as [registered on Bitly](http://bit.ly/a/account)
      def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
        client_options = {
          :site => 'https://bit.ly',
          :authorize_url => 'https://bit.ly/oauth/authorize',
          :access_token_url => 'https://api-ssl.bit.ly/oauth/access_token'
        }

        super(app, :bitly, api_key, secret_key, client_options, options, &block)
      end

      protected

      def user_data
        {
          'login' => @access_token['login'],
          'api_key' => @access_token['apiKey']
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token['login'],
          'user_info' => user_data,
          'extra' => {'user_hash' => user_data}
        })
      end
    end

  end

end
