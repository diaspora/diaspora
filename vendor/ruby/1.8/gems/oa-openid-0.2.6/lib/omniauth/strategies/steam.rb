require 'omniauth/openid'
module OmniAuth
  module Strategies
    class Steam < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, api_key = nil, options = {}, &block)
        options[:identifier] ||= "http://steamcommunity.com/openid"
        options[:name] ||= 'steam'
        @api_key = api_key
        super(app, store, options, &block)
      end

      def user_info(response=nil)
        player = user_hash['response']['players']['player'].first
        nickname = player["personaname"]
        name = player["realname"]
        url = player["profileurl"]
        country = player["loccountrycode"]
        state = player["locstatecode"]
        city = player["loccityid"]

        {
          'nickname' => nickname,
          'name' => name,
          'url' => url,
          'location' => "#{city}, #{state}, #{country}"
        }
      end

      def user_hash
        # Steam provides no information back on a openid response other than a 64bit user id
        # Need to use this information and make a API call to get user information from steam.
        if @api_key
          unless @user_hash
            uri = URI.parse("http://api.steampowered.com/")
            req = Net::HTTP::Get.new("#{uri.path}ISteamUser/GetPlayerSummaries/v0001/?key=#{@api_key}&steamids=#{@openid_response.display_identifier.split("/").last}")
            res = Net::HTTP.start(uri.host, uri.port) {|http|
              http.request(req)
            }
          end
          @user_hash ||= MultiJson.decode(res.body)
        else
          {}
        end
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @openid_response.display_identifier.split("/").last,
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
    end
  end
end
