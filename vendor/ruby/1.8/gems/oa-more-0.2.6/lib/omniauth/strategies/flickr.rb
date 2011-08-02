require 'omniauth/core'
require 'digest/md5'
require 'rest-client'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Flickr
    #
    # @example Basic Usage
    #
    #     use OmniAuth::Strategies::Flickr, 'API Key', 'Secret Key', :scope => 'read'
    class Flickr
      include OmniAuth::Strategy
      attr_accessor :api_key, :secret_key, :options

      # error catching, based on OAuth2 callback
      class CallbackError < StandardError
        attr_accessor :error, :error_reason
        def initialize(error, error_reason)
          self.error = error
          self.error_reason = error_reason
        end
      end

      # @param [Rack Application] app standard middleware application parameter
      # @param [String] api_key the application id as [registered on Flickr](http://www.flickr.com/services/apps/)
      # @param [String] secret_key the application secret as [registered on Flickr](http://www.flickr.com/services/apps/)
      # @option options ['read','write','delete] :scope ('read') the scope of your authorization request; must be `read` or 'write' or 'delete'
      def initialize(app, api_key, secret_key, options = {})
        super(app, :flickr)
        @api_key = api_key
        @secret_key = secret_key
        @options = {:scope => 'read'}.merge(options)
      end

      protected

      def request_phase
        params = { :api_key => api_key, :perms => options[:scope] }
        params[:api_sig] = flickr_sign(params)
        query_string = params.collect{ |key,value| "#{key}=#{Rack::Utils.escape(value)}" }.join('&')
        redirect "http://flickr.com/services/auth/?#{query_string}"
      end

      def callback_phase
        params = { :api_key => api_key, :method => 'flickr.auth.getToken', :frob => request.params['frob'], :format => 'json', :nojsoncallback => '1' }
        params[:api_sig] = flickr_sign(params)

        response = RestClient.get('http://api.flickr.com/services/rest/', { :params => params })
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
          'user_info' => user_info,
          'extra' => { 'user_hash' => @user }
        })
      end

      def user_info
        name = @user['fullname']
        name = @user['username'] if name.nil? || name.empty?
        {
          'nickname' => @user['username'],
          'name' => name,
        }
      end

      def flickr_sign(params)
        Digest::MD5.hexdigest(secret_key + params.sort{|a,b| a[0].to_s <=> b[0].to_s }.flatten.join)
      end
    end
  end
end
