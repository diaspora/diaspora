require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to TradeMe via OAuth and retrieve basic user information.
    # Usage:
    #    use OmniAuth::Strategies::TradeMe, 'consumerkey', 'consumersecret'
    #
    class TradeMe < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        super(app, :trademe, consumer_key, consumer_secret,
                {:site               => 'https://secure.trademe.co.nz',
                :request_token_path  => "/Oauth/RequestToken",
                :access_token_path   => "/Oauth/AccessToken",
                :authorize_path      => "/Oauth/Authorize",
                }, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid'       => user_hash['MemberId'],
          'user_info' => user_info,
          'extra'     => { 'user_hash' => user_hash },
        })
      end

      # user info according to schema
      def user_info
        {
          'nickname'   => user_hash['Nickname'],
          'first_name' => user_hash['FirstName'],
          'last_name'  => user_hash['LastName'],
          'name'       => [user_hash['FirstName'],user_hash['LastName']].reject{ |n| n.nil? || n.empty? }.join(' '),
        }
      end

      # info as supplied by TradeMe user summary
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('https://api.trademe.co.nz/v1/MyTradeMe/Summary.json').body)
      end
    end
  end
end
