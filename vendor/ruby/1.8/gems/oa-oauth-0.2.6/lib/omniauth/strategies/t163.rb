require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to T163 via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::T163, 'APIKey', 'APIKeySecret'
    #
    class T163 < OmniAuth::Strategies::OAuth

      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        @api_key = consumer_key

        client_options = {
          :site               => 'http://api.t.163.com',
          :request_token_path => '/oauth/request_token',
          :access_token_path  => '/oauth/access_token',
          :authorize_path     => '/oauth/authenticate',
          :realm              => 'OmniAuth'
        }

        super(app, :t163, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['screen_name'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash
        {
          'username' => user_hash['name'],
          'name' => user_hash['realName'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {
            'T163' => 'http://t.163.com'
          }
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("http://api.t.163.com/account/verify_credentials.json").body)
      end
    end
  end
end
