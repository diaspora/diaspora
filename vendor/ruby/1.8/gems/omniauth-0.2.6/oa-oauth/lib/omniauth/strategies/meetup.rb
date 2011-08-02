require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate with Meetup via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Meetup, 'consumerkey', 'consumersecret'
    #
    class Meetup < OmniAuth::Strategies::OAuth
      # Initialize meetup middleware
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] consumer_key the application consumer id
      # @param [String] consumer_secret the application consumer secret
      # @option options [Boolean, true] :sign_in When true, use a sign-in flow instead of the authorization flow.
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        auth_path = (options[:sign_in] == false) ? 'http://www.meetup.com/authorize' : 'http://www.meetup.com/authenticate'

        super(app, :meetup, consumer_key, consumer_secret,
                { :request_token_path  => "https://api.meetup.com/oauth/request",
                  :access_token_path   => "https://api.meetup.com/oauth/access",
                  :authorize_path      => auth_path }, options)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => member['id'],
          'user_info' => user_info,
          'extra' => { 'user_hash' => member }
        })
      end

      def user_info
        {
          'name' => member['name'],
          'image' => member['photo_url'],
          'location' => member['city'],
          'urls' => {
            'profile' => member['link']
          }
        }
      end

      def member
        @member ||= parse(@access_token.get('https://api.meetup.com/members.json?relation=self').body)['results'][0]
      end

      def parse(response)
        MultiJson.decode(response)
      end
    end
  end
end
