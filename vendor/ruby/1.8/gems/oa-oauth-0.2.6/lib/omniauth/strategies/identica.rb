require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Identica via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Identica, 'consumerkey', 'consumersecret'
    #
    class Identica < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        super(app, :identica, consumer_key, consumer_secret,
                {:site => 'http://identi.ca',
                :request_token_path => "/api/oauth/request_token",
                :access_token_path  => "/api/oauth/access_token",
                :authorize_path     => "/api/oauth/authorize"}, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash

        {
          'nickname' => user_hash['screen_name'],
          'name' => user_hash['name'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {'Website' => user_hash['url']}
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/api/account/verify_credentials.json').body)
      end
    end
  end
end
