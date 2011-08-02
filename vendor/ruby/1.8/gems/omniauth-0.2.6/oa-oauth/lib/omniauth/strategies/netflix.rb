require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Netflix via OAuth and retrieve basic user information.
    # Usage:
    #    use OmniAuth::Strategies::Netflix, 'consumerkey', 'consumersecret'
    #
    class Netflix < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        opts = {
          :site               => 'http://api.netflix.com',
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_url      => "https://api-user.netflix.com/oauth/login"
        }
        super(app, :netflix, consumer_key, consumer_secret, opts, options, &block)
      end

      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => request_token.callback_confirmed?, 'request_token' => request_token.token, 'request_secret' => request_token.secret}
        r = Rack::Response.new

        if request_token.callback_confirmed?
          r.redirect(request_token.authorize_url(
            :oauth_consumer_key => consumer.key
          ))
        else
          r.redirect(request_token.authorize_url(
            :oauth_callback => callback_url,
            :oauth_consumer_key => consumer.key
          ))
        end

        r.finish
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['user']['user_id'],
          'user_info' => user_info,
          'extra' => { 'user_hash' => user_hash['user'] }
        })
      end

      def user_info
        user = user_hash['user']
        {
          'nickname' => user['nickname'],
          'first_name' => user['first_name'],
          'last_name' => user['last_name'],
          'name' => "#{user['first_name']} #{user['last_name']}"
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("http://api.netflix.com/users/#{@access_token.params[:user_id]}?output=json").body)
      end
    end
  end
end
