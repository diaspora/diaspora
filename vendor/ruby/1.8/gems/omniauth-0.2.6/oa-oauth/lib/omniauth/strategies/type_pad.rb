require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Typepad via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Typepad, 'consumerkey', 'consumersecret', :application_id => 'my_type_pad_application_id'
    #
    #    application_id is required.
    #
    class TypePad < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)

        # TypePad uses the application ID for one of the OAuth paths.
        app_id = options[:application_id]

        client_options = {
          :site => 'https://www.typepad.com',
          :request_token_path => '/secure/services/oauth/request_token',
          :access_token_path => '/secure/services/oauth/access_token',
          :authorize_path => "/secure/services/api/#{app_id}/oauth-approve",
          :http_method => :get,
          # You *must* use query_string for the token dance.
          :scheme => :query_string
        }

        options.merge! :scheme => :query_string, :http_method => :get

        super(app, :type_pad, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash

        {
          'uid' => user_hash['urlId'],
          'nickname' => user_hash['preferredUsername'],
          'name' => user_hash['displayName'],
          'image' => user_hash['avatarLink']['url'],
          'description' => user_hash['aboutMe'],
          'urls' => {'Profile' => user_hash['profilePageUrl']}
        }
      end

      def user_hash
        # For authenticated requests, you have to use header as your scheme.
        # Failure to do so gives a unique response body - 'Auth is required'.
        # 'Unauthorized' is the response body of a truly unauthorized request.

        # Also note that API requests hit a different site than the OAuth dance.
        r = self.consumer.request(
              :get,
              "https://api.typepad.com/users/@self.json",
              @access_token,
              :scheme => 'header'
            )

        @user_hash ||= MultiJson.decode(r.body)
      end
    end
  end
end
