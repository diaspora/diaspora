require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Yammer < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://www.yammer.com',
          :request_token_path => '/oauth/request_token',
          :access_token_path => '/oauth/access_token',
          :authorize_path => "/oauth/authorize"
        }

        super(app, :yammer, consumer_key, consumer_secret, client_options, options)
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
          'nickname' => user_hash['name'],
          'name' => user_hash['full-name'],
          'location' => user_hash['location'],
          'image' => user_hash['mugshot-url'],
          'description' => user_hash['job-title'],
          'urls' => {'Yammer' => user_hash['web-url']}
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/api/v1/users/current.json').body)
      end
    end
  end
end
