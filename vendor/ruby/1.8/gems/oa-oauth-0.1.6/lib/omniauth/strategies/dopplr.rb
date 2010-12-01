require 'omniauth/oauth'

module OmniAuth
  module Strategies
    #
    # Authenticate to Dopplr via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Dopplr, 'consumerkey', 'consumersecret'
    #
    class Dopplr < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :dopplr, consumer_key, consumer_secret,
                :site => 'https://www.dopplr.com',
                :request_token_path => "/oauth/request_token",
                :access_token_path  => "/oauth/access_token",
                :authorize_path    => "/oauth/authorize")
      end     
    end
  end
end
