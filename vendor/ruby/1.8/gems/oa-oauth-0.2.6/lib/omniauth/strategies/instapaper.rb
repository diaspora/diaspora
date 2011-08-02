require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Instapaper < OmniAuth::Strategies::XAuth

      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :title => 'Instapaper',
          :site => 'https://www.instapaper.com',
          :access_token_path => '/api/1/oauth/access_token'
        }
        super(app, :instapaper, consumer_key, consumer_secret, client_options, options, &block)
      end

      protected

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/api/1/account/verify_credentials').body)[0]
      end

      def user_info
        {
          'nickname' => user_data['username'],
          'name' => user_data['username']
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['user_id'],
          'user_info' => user_info
        })
      end

    end
  end
end

