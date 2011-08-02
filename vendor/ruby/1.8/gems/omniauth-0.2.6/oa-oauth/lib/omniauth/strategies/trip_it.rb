require 'omniauth/oauth'

module OmniAuth
  module Strategies
    #
    # Authenticate to TripIt via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::TripIt, 'consumerkey', 'consumersecret'
    #
    class TripIt < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        super(app, :tripit, consumer_key, consumer_secret,
                {:site => 'https://api.tripit.com',
                :request_token_path => "/oauth/request_token",
                :access_token_path  => "/oauth/access_token",
                :authorize_url     => "https://www.tripit.com/oauth/authorize"}, options, &block)
      end
    end
  end
end
