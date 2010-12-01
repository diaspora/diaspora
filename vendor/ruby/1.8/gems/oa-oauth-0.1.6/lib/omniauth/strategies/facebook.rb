require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Facebook utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #   use OmniAuth::Strategies::Facebook, 'app_id', 'app_secret'
    class Facebook < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] app_id the application id as [registered on Facebook](http://www.facebook.com/developers/)
      # @param [String] app_secret the application secret as registered on Facebook
      # @option options [String] :scope ('email,offline_access') comma-separated extended permissions such as `email` and `manage_pages`
      def initialize(app, app_id, app_secret, options = {})
        options[:site] = 'https://graph.facebook.com/'
        super(app, :facebook, app_id, app_secret, options)
      end
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/me', {}, { "Accept-Language" => "en-us,en;"}))
      end
      
      def request_phase
        options[:scope] ||= "email,offline_access"
        super
      end
      
      def user_info
        {
          'nickname' => user_data["link"].split('/').last,
          'first_name' => user_data["first_name"],
          'last_name' => user_data["last_name"],
          'name' => "#{user_data['first_name']} #{user_data['last_name']}",
          'urls' => {
            'Facebook' => user_data["link"],
            'Website' => user_data["website"],
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