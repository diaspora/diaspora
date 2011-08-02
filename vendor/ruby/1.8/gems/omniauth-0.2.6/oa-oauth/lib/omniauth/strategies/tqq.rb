require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Tqq via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Tqq, 'APIKey', 'APIKeySecret'
    #
    class Tqq < OmniAuth::Strategies::OAuth

      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        @api_key = consumer_key

        client_options = {
          :site               => 'https://open.t.qq.com',
          :request_token_path => '/cgi-bin/request_token',
          :access_token_path  => '/cgi-bin/access_token',
          :authorize_path     => '/cgi-bin/authorize',
          :realm              => 'OmniAuth',
          :scheme             => :query_string,
          :nonce              => nonce,
          :http_method        => :get,
        }

        super(app, :tqq, consumer_key, consumer_secret, client_options, options, &block)
      end

      def nonce
        Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32]
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash["data"]['uid'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash
        {
          'username' => user_hash["data"]['name'],
          'name' => user_hash["data"]['nick'],
          'location' => user_hash["data"]['location'],
          'image' => user_hash["data"]['head'],
          'description' => user_hash['description'],
          'urls' => {
            'Tqq' => 't.qq.com'
          }
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("http://open.t.qq.com/api/user/info?format=json").body)
      end
    end
  end
end
