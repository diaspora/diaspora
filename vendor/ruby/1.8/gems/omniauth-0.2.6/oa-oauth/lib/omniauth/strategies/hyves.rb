require 'omniauth/oauth'
require 'multi_json'


module OmniAuth
  module Strategies
    class Hyves < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :request_token_path => request_token_path,
          :authorize_path => "http://www.hyves.nl/api/authorize",
          :access_token_path => access_token_path,
          :http_method => :get,
          :scheme => :header
        }
        super(app, :hyves, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        hash = user_hash(@access_token)

        {
          "provider" => "hyves",
          "uid" => hash["userid"],
          "user_info" => {
            "name" => hash["firstname"] + " " + hash["lastname"],
            "first_name" => hash["firstname"],
            "last_name" => hash["lastname"]
          },
          "credentials" => {
            "token" => @access_token.token,
            "secret" => @access_token.secret
          }
        }
      end

      def user_hash(access_token)
        rsp = MultiJson.decode( access_token.get("http://data.hyves-api.nl/?userid=#{access_token.params[:userid]}&ha_method=users.get&#{default_options}").body )
        rsp["user"].first
      end

      def request_token_path
        "http://data.hyves-api.nl/?#{request_token_options}&#{default_options}"
      end

      def access_token_path
        "http://data.hyves-api.nl/?#{access_token_options}&#{default_options}"
      end

      def default_options
        to_params( { :ha_version => "2.0", :ha_format => "json", :ha_fancylayout => false } )
      end

      def request_token_options
        to_params( { :methods => "users.get,friends.get,wwws.create", :ha_method => "auth.requesttoken", :strict_oauth_spec_response => true } )
      end

      def access_token_options
        to_params( { :ha_method => "auth.accesstoken", :strict_oauth_spec_response => true } )
      end

      def to_params(options)
        options.collect { |key, value| "#{key}=#{value}"}.join('&')
      end
    end
  end
end
