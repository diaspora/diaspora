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
      def initialize(app, consumer_key, consumer_secret)
        super(app, :twitter, consumer_key, consumer_secret,
                :site => 'https://api.twitter.com',
                :authorize_path => '/oauth/authenticate')
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
          'name' => user_hash['name'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {'Website' => user_hash['url']}
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/1/account/verify_credentials.json').body)
      end
    end
  end
end
