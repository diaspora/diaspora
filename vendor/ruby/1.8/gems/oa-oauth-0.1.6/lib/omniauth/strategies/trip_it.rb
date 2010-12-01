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
      def initialize(app, consumer_key, consumer_secret)
        super(app, :tripit, consumer_key, consumer_secret,
                :site => 'https://api.tripit.com',
                :request_token_path => "/oauth/request_token",
                :access_token_path  => "/oauth/access_token",
                :authorize_url     => "https://www.tripit.com/oauth/authorize")
      end
      
      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        (session[:oauth]||={})[name.to_sym] = {:callback_confirmed => request_token.callback_confirmed?, :request_token => request_token.token, :request_secret => request_token.secret}
        r = Rack::Response.new
        # For some reason, TripIt NEEDS the &oauth_callback query param or the user receives an error.
        r.redirect request_token.authorize_url + "&oauth_callback=" + urlencode(callback_url)
        r.finish
      end
      
      def urlencode(str)
        str.gsub(/[^a-zA-Z0-9_\.\-]/n) { sprintf('%%%02x', $&[0].ord) }
      end
    end
  end
end
