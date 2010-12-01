require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # OAuth 2.0 based authentication with GitHub. In order to 
    # sign up for an application, you need to [register an application](http://github.com/account/applications/new)
    # and provide the proper credentials to this middleware.
    class GitHub < OAuth2
      # @param [Rack Application] app standard middleware application argument
      # @param [String] app_id the application ID for your client
      # @param [String] app_secret the application secret
      def initialize(app, app_id, app_secret, options = {})
        options[:site] = 'https://github.com/'
        options[:authorize_path] = '/login/oauth/authorize'
        options[:access_token_path] = '/login/oauth/access_token'
        super(app, :github, app_id, app_secret, options)
      end
      
      protected
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/api/v2/json/user/show'))['user']
      end
      
      def user_info
        {
          'nickname' => user_data["login"],
          'email' => user_data['email'],
          'name' => user_data['name'],
          'urls' => {
            'GitHub' => "http://github.com/#{user_data['login']}",
            'Blog' => user_data["blog"],
          }
        }
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end
    end
  end
end
