require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Vkontakte utilizing OAuth 2.0 and retrieve
    # basic user information.
    # documentation available here:
    # http://vkontakte.ru/developers.php?o=-17680044&p=Authorization&s=0
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Vkontakte, 'API Key', 'Secret Key'
    class Vkontakte < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] api_key the application id as [registered in Vkontakte]
      # @param [String] secret_key the application secret as [registered in Vkontakte]
      def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
        client_options = {
          :site => 'https://vkontakte.ru',
          :authorize_url => 'http://api.vkontakte.ru/oauth/authorize',
          :access_token_url => 'https://api.vkontakte.ru/oauth/token'
        }

        super(app, :vkontakte, api_key, secret_key, client_options, options, &block)
      end

      protected

      def user_data
        # http://vkontakte.ru/developers.php?o=-17680044&p=Description+of+Fields+of+the+fields+Parameter
        @fields ||= ['uid', 'first_name', 'last_name', 'nickname', 'domain', 'sex', 'bdate', 'city', 'country', 'timezone', 'photo', 'photo_big']

        # http://vkontakte.ru/developers.php?o=-1&p=getProfiles
        @data ||= MultiJson.decode(@access_token.get("https://api.vkontakte.ru/method/getProfiles?uid=#{@access_token['user_id']}&fields=#{@fields.join(',')}&access_token=#{@access_token.token}"))['response'][0]

        # we need these 2 additional requests since vkontakte returns only ids of the City and Country
        # http://vkontakte.ru/developers.php?o=-17680044&p=getCities
        cities = MultiJson.decode(@access_token.get("https://api.vkontakte.ru/method/getCities?cids=#{@data['city']}&access_token=#{@access_token.token}"))['response']
        @city ||= cities.first['name'] if cities && cities.first

        # http://vkontakte.ru/developers.php?o=-17680044&p=getCountries
        countries = MultiJson.decode(@access_token.get("https://api.vkontakte.ru/method/getCountries?cids=#{@data['country']}&access_token=#{@access_token}"))['response']
        @country ||= countries.first['name'] if countries && countries.first
      end

    def request_phase
      options[:response_type] ||= 'code'
      super
    end

    def user_info
      {
        'first_name' => @data['first_name'],
        'last_name' => @data['last_name'],
        'name' => "#{@data['first_name']} #{@data['last_name']}",
        'nickname' => @data['nickname'],
        'birth_date' => @data['bdate'],
        'image' => @data['photo'],
        'location' => "#{@country}, #{@city}",
        'urls' => {
          'Vkontakte' => "http://vkontakte.ru/#{@data['domain']}"
        }
      }
    end

    def user_hash
      {
        "user_hash" => {
          "gender" => @data["sex"],
          "timezone" => @data["timezone"],
          "photo_big" => @data["photo_big"] # 200px maximum resolution of the avatar (http://vkontakte.ru/developers.php?o=-17680044&p=Description+of+Fields+of+the+fields+Parameter)
        }
      }
    end

    def auth_hash
      user_data # process user's info
      OmniAuth::Utils.deep_merge(super, {
        'uid' => @data['uid'],
        'user_info' => user_info,
        'extra' => user_hash
      })
    end
  end
end
end
