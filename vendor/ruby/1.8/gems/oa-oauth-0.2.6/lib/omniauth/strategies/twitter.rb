require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Twitter via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Twitter, 'consumerkey', 'consumersecret'
    #
    class Twitter < OmniAuth::Strategies::OAuth
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use the "Sign in with Twitter" flow instead of the authorization flow.
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://api.twitter.com'
        }

        options[:authorize_params] = {:force_login => 'true'} if options.delete(:force_login) == true
        client_options[:authorize_path] = '/oauth/authenticate' unless options[:sign_in] == false
        super(app, :twitter, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:user_id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash

        {
          'nickname' => user_hash['screen_name'],
          'name' => user_hash['name'] || user_hash['screen_name'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {
            'Website' => user_hash['url'],
            'Twitter' => 'http://twitter.com/' + user_hash['screen_name']
          }
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/1/account/verify_credentials.json').body)
      end
    end
  end
end
