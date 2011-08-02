require 'omniauth/core'
require 'digest/md5'
require 'rest-client'
require 'multi_json'

module OmniAuth
  module Strategies
    class Yupoo
      include OmniAuth::Strategy
      attr_accessor :api_key, :secret_key, :options


      class CallbackError < StandardError
        attr_accessor :error, :error_reason
        def initialize(error, error_reason)
          self.error = error
          self.error_reason = error_reason
        end
      end

      def initialize(app, api_key, secret_key, options = {})
        super(app, :yupoo)
        @api_key = api_key
        @secret_key = secret_key
        @options = {:scope => 'read'}.merge(options)
      end

      protected

      def request_phase
        params = { :api_key => api_key, :perms => options[:scope] }
        params[:api_sig] = yupoo_sign(params)
        query_string = params.collect{ |key,value| "#{key}=#{Rack::Utils.escape(value)}" }.join('&')
        redirect "http://www.yupoo.com/services/auth/?#{query_string}"
      end

      def callback_phase
        params = { :api_key => api_key, :method => 'yupoo.auth.getToken', :frob => request.params['frob'], :format => 'json', :nojsoncallback => '1' }
        params[:api_sig] = yupoo_sign(params)

        response = RestClient.get('http://www.yupoo.com/api/rest/', { :params => params })
        auth = MultiJson.decode(response.to_s)
        raise CallbackError.new(auth['code'],auth['message']) if auth['stat'] == 'fail'

        @user = auth['auth']['user']
        @access_token = auth['auth']['token']['_content']

        super
      rescue CallbackError => e
        fail!(:invalid_response, e)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @user['nsid'],
          'credentials' => { 'token' => @access_token },
          'user_info' => @user,
          'extra' => { 'user_hash' => @user }
        })
      end

      def yupoo_sign(params)
        Digest::MD5.hexdigest(secret_key + params.sort{|a,b| a[0].to_s <=> b[0].to_s }.flatten.join)
      end
    end
  end
end
