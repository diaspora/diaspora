require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Salesforce < OmniAuth::Strategies::OAuth2
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://login.salesforce.com',
          :authorize_path => '/services/oauth2/authorize',
          :access_token_path => '/services/oauth2/token'
        }

        options.merge!(:response_type => 'code', :grant_type => 'authorization_code')

        super(app, :salesforce, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        data = user_data
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token['id'],
          'credentials' => {
            'instance_url' => @access_token['instance_url']
           },
          'extra' => {'user_hash' => data},
          'user_info' => {
            'email' => data['email'],
            'name' => data['display_name']
          }
        })
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get(@access_token['id']))
      rescue ::OAuth2::HTTPError => e
        if e.response.status == 302
          @data ||= MultiJson.decode(@access_token.get(e.response.headers['location']))
        else
          raise e
        end
      end
    end
  end
end
