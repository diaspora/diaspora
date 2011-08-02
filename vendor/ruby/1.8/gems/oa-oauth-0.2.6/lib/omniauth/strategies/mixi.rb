require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Facebook utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #   use OmniAuth::Strategies::Mixi, 'client_id', 'client_secret'
    class Mixi < OAuth2
      # @option options [String] :scope separate the scopes by a space
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => "https://mixi.jp/",
          :authorize_url      => "/connect_authorize.pl",
          :access_token_url   => "https://secure.mixi-platform.com/2/token"
        }

        super(app, :mixi, client_id, client_secret, client_options, options, &block)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get(
          "http://api.mixi-platform.com/2/people/@me/@self",
          {'oauth_token' => @access_token.token}
        ))
      end

      def request_phase
        options[:scope] ||= "r_profile"
        options[:display] ||= "pc"
        options[:response_type] ||= 'code'
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_info
        {
          'nickname' => user_data['entry']['displayName'],
          'image' => user_data['entry']['thumbnailUrl'],
          'urls' => {:profile => user_data['entry']['profileUrl']}
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['entry']['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data['entry']}
        })
      end
    end
  end
end
