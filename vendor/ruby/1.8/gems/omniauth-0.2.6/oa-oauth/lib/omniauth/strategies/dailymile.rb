require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to DailyMile utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::DailyMile, 'CLIENT_ID', 'CLIENT_SECRET'
    class Dailymile < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on Dailymile](http://www.dailymile.com/api/consumers/new)
      # @param [String] cliend_secret the application secret as [registered on Dailymile](http://www.dailymile.com/api/consumers/new)
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://api.dailymile.com/oauth',
          :authorize_path => '/oauth/authorize',
          :access_token_path => '/oauth/token'
        }

        super(app, :dailymile, client_id, client_secret, client_options, options, &block)
      end

      protected

      def user_data
        @data ||= MultiJson.decode(@access_token.get("/people/me.json"))
      end

      def request_phase
        options[:response_type] ||= 'code'
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_info
        {
          'name' => user_data['display_name'],
          'nickname' => user_data['username'],
          'location' => user_data['location'],
          'image' => user_data['photo_url'],
          'description' => user_data['goal'],
          'urls' => {
            'dailymile' => user_data['url']
          }
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data["url"].split('/').last,
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end
    end
  end
end
