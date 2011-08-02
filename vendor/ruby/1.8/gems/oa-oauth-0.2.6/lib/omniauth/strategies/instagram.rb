require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Facebook utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #   use OmniAuth::Strategies::Instagram, 'client_id', 'client_secret'
    class Instagram < OAuth2
      # @option options [String] :scope separate the scopes by a space
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => "https://api.instagram.com/",
          :authorize_url      => "/oauth/authorize",
          :access_token_url   => "/oauth/access_token"
        }

        super(app, :instagram, client_id, client_secret, client_options, options, &block)
      end

      def request_phase
        options[:scope] ||= "basic"
        options[:response_type] ||= 'code'
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get("/v1/users/self"))
      end

      def user_info
        {
          'nickname' => user_data['data']['username'],
          'name' => user_data['data']['full_name'],
          'image' => user_data['data']['profile_picture'],
          'urls' => {}
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['data']['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data['data']}
        })
      end
    end
  end
end
