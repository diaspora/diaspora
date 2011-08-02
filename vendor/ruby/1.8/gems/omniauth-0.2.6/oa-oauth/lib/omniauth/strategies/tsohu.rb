require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Tsohu via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Tsohu, 'APIKey', 'APIKeySecret'
    #
    class Tsohu < OmniAuth::Strategies::OAuth

      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        @api_key = consumer_key

        client_options = {
          :site               => 'http://api.t.sohu.com',
          :request_token_path => '/oauth/request_token',
          :access_token_path  => '/oauth/access_token',
          :authorize_path     => '/oauth/authorize',
          :scheme             => :header,
        }

        super(app, :tsohu, consumer_key, consumer_secret, client_options, options, &block)
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
          'username' => user_hash['screen_name'],
          'name' => user_hash['name'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {
            'Tsohu' => user_hash['url']
          }
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("http://api.t.sohu.com/account/verify_credentials.json").body)
      end
    end
  end
end
