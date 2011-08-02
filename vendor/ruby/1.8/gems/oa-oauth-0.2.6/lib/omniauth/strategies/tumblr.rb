require 'omniauth/oauth'

module OmniAuth
  module Strategies
    #
    # Authenticate to Tumblr via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Tumblr, 'consumerkey', 'consumersecret'
    #
    class Tumblr < OmniAuth::Strategies::OAuth
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use the "Sign in with Tumblr" flow instead of the authorization flow.
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'http://www.tumblr.com'
        }

        client_options[:authorize_path] = '/oauth/authorize' unless options[:sign_in] == false
        super(app, :tumblr, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user['name'],
          'user_info' => user_info,
          'extra' => { 'user_hash' => user }
        })
      end

      def user_info
        {
          'nickname' => user['name'],
          'name' => user['title'],
          'image' => user['avatar_url'],
          'urls' => {
            'website' => user['url'],
          }
        }
      end

      def user
        tumblelogs = user_hash['tumblr']['tumblelog']
        if tumblelogs.kind_of?(Array)
          @user ||= tumblelogs[0]
        else
          @user ||= tumblelogs
        end
      end

      def user_hash
        url = "http://www.tumblr.com/api/authenticate"
        @user_hash ||= Hash.from_xml(@access_token.get(url).body)
      end
    end
  end
end
