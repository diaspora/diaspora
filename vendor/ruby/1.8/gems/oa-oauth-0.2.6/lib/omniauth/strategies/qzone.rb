require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to qzone (QQ) via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Qzone, 'consumerkey', 'consumersecret'
    #
    class Qzone < OmniAuth::Strategies::OAuth
      # Initialize the middleware
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'http://openapi.qzone.qq.com',
          :request_token_path => '/oauth/qzoneoauth_request_token',
          :access_token_path  => '/oauth/qzoneoauth_access_token',
          :authorize_path     => '/oauth/qzoneoauth_authorize',
          :scheme             => :query_string,
          :http_method        => :get
        }

        options[:authorize_params] = {:oauth_consumer_key => consumer_key}
        super(app, :qzone, consumer_key, consumer_secret, client_options, options)
      end

      #HACK qzone is using a none-standard parameter oauth_overicode
      def consumer_options
        @consumer_options[:access_token_path] = '/oauth/qzoneoauth_access_token?oauth_vericode=' + request['oauth_vericode'] if request['oauth_vericode']
        @consumer_options
      end

      def callback_phase
        session['oauth'][name.to_s]['callback_confirmed'] = true
        super
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
          'uid' => @access_token.params[:openid],
          'nickname' => user_hash['nickname'],
          'name' =>  user_hash['nickname'],
          'image' => user_hash['figureurl'],
          'urls' => {
            'figureurl_1' => user_hash['figureurl_1'],
            'figureurl_2' => user_hash['figureurl_2'],
          }
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("/user/get_user_info?format=json&openid=#{@access_token.params[:openid]}").body)
      end
    end
  end
end
