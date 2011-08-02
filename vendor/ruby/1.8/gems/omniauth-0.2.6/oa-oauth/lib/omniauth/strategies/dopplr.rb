require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Dopplr via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Dopplr, 'consumerkey', 'consumersecret'
    #
    class Dopplr < OmniAuth::Strategies::OAuth
      # Initialize the Dopplr strategy.
      #
      # @option options [Hash, {}] :client_options Options to be passed directly to the OAuth Consumer
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://www.dopplr.com',
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path    => "/oauth/authorize"
        }

        super(app, :dopplr, consumer_key, consumer_secret, client_options, options, &block)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/oauthapi/whoami').body)['whoami']
      end

      def user_info
        {
          'nickname' => user_data["nick"],
          'first_name' => user_data["forename"],
          'last_name' => user_data["surname"],
          'name' => "#{user_data['forename']} #{user_data['surname']}",
          'urls' => {
            'Dopplr' => user_data["dopplr_url"],
            'DopplrMobile' => user_data["mobile_url"],
          }
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['nick'],
          'user_info' => user_info
        })
      end
    end
  end
end
