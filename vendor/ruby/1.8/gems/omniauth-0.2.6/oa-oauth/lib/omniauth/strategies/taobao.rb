require 'omniauth/oauth'
require 'multi_json'
require 'digest/md5'
require 'net/http'

module OmniAuth
  module Strategies
    # Authenticate to Renren utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    # use OmniAuth::Strategies::TB, 'client_id', 'client_secret'
    class TB < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the app key at taobao open platform
      # @param [String] client_secret  the app secret at taobao open platform
      # @option options [String]

      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => "https://oauth.taobao.com/",
          :authorize_url => "/authorize",
          :access_token_url => "/token"
        }

        super(app, :tb, client_id, client_secret, client_options, options, &block)
      end

      def user_data
        # TODO to be moved in options
        url = 'http://gw.api.taobao.com/router/rest'

        query_param = {
          :app_key => client_id,

          # TODO to be moved in options
          # TODO add more default fields (http://my.open.taobao.com/apidoc/index.htm#categoryId:1-dataStructId:3)
          :fields => 'user_id,uid,nick,sex,buyer_credit,seller_credit,location,created,last_visit,birthday,type,status,alipay_no,alipay_account,alipay_account,email,consumer_protection,alipay_bind',
          :format => 'json',
          :method => 'taobao.user.get',
          :session => @access_token.token,
          :sign_method => 'md5',
          :timestamp   => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
          :v => '2.0'
        }
        query_param = generate_sign(query_param)
        res = Net::HTTP.post_form(URI.parse(url), query_param)
        @data ||= MultiJson.decode(res.body)["user_get_response"]["user"]
      end

      def request_phase
        options[:state] ||= '1'
        super
      end

      def user_info
        {
          'name' => user_data["nick"],
          'email' => (user_data["email"] if user_data["email"]),
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['uid'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end

      def generate_sign(params)
        str = client_secret + (params.sort.collect { |k, v| "#{k}#{v}" }).join + client_secret
        params["sign"] = Digest::MD5.hexdigest(str).upcase!
        params
      end

    end
  end
end
