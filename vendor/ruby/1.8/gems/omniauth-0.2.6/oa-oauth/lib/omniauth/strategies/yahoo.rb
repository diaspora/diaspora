require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Yahoo via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Yahoo, 'consumerkey', 'consumersecret'
    #
    class Yahoo < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://api.login.yahoo.com',
          :request_token_path => '/oauth/v2/get_request_token',
          :access_token_path => '/oauth/v2/get_token',
          :authorize_path => "/oauth/v2/request_auth"
        }

        super(app, :yahoo, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash
        profile = user_hash['profile']
        nickname = user_hash['profile']['nickname']
        {
          'uid' => profile['guid'],
          'nickname' => profile['nickname'],
          'name' => profile['givenName'] || nickname,
          'image' => profile['image']['imageUrl'],
          'description' => profile['message'],
          'urls' => {'Profile' => profile['profileUrl'] }
        }
      end

      def user_hash
        uid = @access_token.params['xoauth_yahoo_guid']
        @user_hash ||= MultiJson.decode(@access_token.get("http://social.yahooapis.com/v1/user/#{uid}/profile?format=json").body)
      end
    end
  end
end
