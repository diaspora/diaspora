require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Teambox < OAuth2
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => "https://teambox.com/",
          :authorize_path => "/oauth/authorize",
          :access_token_path => "/oauth/token"
        }
        super(app, :teambox, client_id, client_secret, client_options, options, &block)
      end
      def request_phase
        options[:scope] ||= "offline_access"
        options[:response_type] ||= 'code'
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get("/api/1/account"))
      end

      def user_info
        {
          'nickname' => user_data['username'],
          'name' => user_data['first_name'],
          'image' => user_data['avatar_url'],
          'urls' => {}
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end
    end
  end
end

