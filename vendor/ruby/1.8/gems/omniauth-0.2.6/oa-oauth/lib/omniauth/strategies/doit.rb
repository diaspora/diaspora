require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Doit < OAuth2
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://openapi.doit.im',
          :authorize_url => 'https://openapi.doit.im/oauth/authorize',
          :access_token_url => 'https://openapi.doit.im/oauth/access_token'
        }

        super(app, :doit, consumer_key, consumer_secret, client_options, options, &block)
      end

      protected

      def user_data
        @data ||= MultiJson.decode(@access_token.get(client.site+"/v1/settings"),{'Authorization'=> 'OAuth'+@access_token.token})
      end

      def request_phase
        options[:response_type] ||= "code"
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_info
        {
          'account' => user_data['account'],
          'username'=> user_data['username'],
          'nickname'=> user_data['nickname'],
          'gender'=> user_data['gender'],
          'week_start'=> user_data['week_start'],
          'birthday_day'=> user_data['birthday_day'],
          'birthday_month'=> user_data['birthday_month'],
          'birthday_year'=> user_data['birthday_year'],
          'language'=> user_data['language'],
          'user_timezone'=> user_data['user_timezone'],
          'remind_email'=> user_data['remind_email'],
          'created'=> user_data['created'],
          'updated'=> user_data['updated']
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
