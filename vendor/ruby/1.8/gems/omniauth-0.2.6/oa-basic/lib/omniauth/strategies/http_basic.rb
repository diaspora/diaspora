require 'rest-client'
require 'omniauth/basic'

module OmniAuth
  module Strategies
    class HttpBasic
      include OmniAuth::Strategy

      def initialize(app, name, endpoint = nil, headers = {}, &block)
        super
        @endpoint = endpoint
        @request_headers = headers
      end

      attr_reader :endpoint, :request_headers

      def request_phase
        if env['REQUEST_METHOD'] == 'GET'
          get_credentials
        else
          perform
        end
      end

      def title
        name.split('_').map{|s| s.capitalize}.join(' ')
      end

      def get_credentials
        OmniAuth::Form.build(:title => title) do
          text_field 'Username', 'username'
          password_field 'Password', 'password'
        end.to_response
      end

      def perform
        @response = perform_authentication(endpoint)
        @env['omniauth.auth'] = auth_hash
        @env['REQUEST_METHOD'] = 'GET'
        @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix}/#{name}/callback"

        call_app!
      rescue RestClient::Request::Unauthorized => e
        fail!(:invalid_credentials, e)
      end

      def perform_authentication(uri, headers = request_headers)
        RestClient.get(uri, headers)
      end

      def callback_phase
        fail!(:invalid_credentials)
      end
    end
  end
end
