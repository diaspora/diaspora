require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class XAuth
      include OmniAuth::Strategy

      attr_reader :name
      attr_accessor :consumer_key, :consumer_secret, :consumer_options

      def initialize(app, name, consumer_key = nil, consumer_secret = nil, consumer_options = {}, options = {}, &block)
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
        self.consumer_options = consumer_options
        super
      end

      def request_phase
        session['oauth'] ||= {}
        if env['REQUEST_METHOD'] == 'GET'
          get_credentials
        else
          session['omniauth.xauth'] = { 'x_auth_mode' => 'client_auth', 'x_auth_username' => request['username'], 'x_auth_password' => request['password'] }
          redirect callback_path
        end
      end

      def get_credentials
        OmniAuth::Form.build(consumer_options[:title] || "xAuth Credentials") do
          text_field 'Username', 'username'
          password_field 'Password', 'password'
        end.to_response
      end

      def consumer
        ::OAuth::Consumer.new(consumer_key, consumer_secret, consumer_options.merge(options[:client_options] || options[:consumer_options] || {}))
      end

      def callback_phase
        @access_token = consumer.get_access_token(nil, {}, session['omniauth.xauth'])
        super
        rescue ::Net::HTTPFatalError => e
          fail!(:service_unavailable, e)
        rescue ::OAuth::Unauthorized => e
          fail!(:invalid_credentials, e)
        rescue ::MultiJson::DecodeError => e
          fail!(:invalid_response, e)
      ensure
        session['omniauth.xauth'] = nil
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'credentials' => {
            'token' => @access_token.token,
            'secret' => @access_token.secret
          }, 'extra' => {
            'access_token' => @access_token
          }
        })
      end

    end
  end
end

