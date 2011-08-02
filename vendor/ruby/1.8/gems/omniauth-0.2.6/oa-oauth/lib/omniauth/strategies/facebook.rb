require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Facebook utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #   use OmniAuth::Strategies::Facebook, 'client_id', 'client_secret'
    class Facebook < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on Facebook](http://www.facebook.com/developers/)
      # @param [String] client_secret the application secret as registered on Facebook
      # @option options [String] :scope ('email,offline_access') comma-separated extended permissions such as `email` and `manage_pages`
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        super(app, :facebook, client_id, client_secret, {:site => 'https://graph.facebook.com/'}, options, &block)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/me', {}, { "Accept-Language" => "en-us,en;"}))
      end

      def request_phase
        options[:scope] ||= "email,offline_access"
        super
      end

      def build_access_token
        if facebook_session.nil? || facebook_session.empty?
          super
        else
          @access_token = ::OAuth2::AccessToken.new(client, facebook_session['access_token'])
        end
      end

      def facebook_session
        session_cookie = request.cookies["fbs_#{client.id}"]
        if session_cookie
          @facebook_session ||= Rack::Utils.parse_query(request.cookies["fbs_#{client.id}"].gsub('"', ''))
        else
          nil
        end
      end

      def user_info
        {
          'nickname' => user_data["username"],
          'email' => (user_data["email"] if user_data["email"]),
          'first_name' => user_data["first_name"],
          'last_name' => user_data["last_name"],
          'name' => "#{user_data['first_name']} #{user_data['last_name']}",
          'image' => "http://graph.facebook.com/#{user_data['id']}/picture?type=square",
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
