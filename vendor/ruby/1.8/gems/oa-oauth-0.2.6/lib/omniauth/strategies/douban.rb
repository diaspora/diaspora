require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Douban via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Douban, 'APIKey', 'APIKeySecret'
    #
    class Douban < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        # Although in OAuth spec the :realm parameter is optional,
        # it is required for Douban.
        client_options = {
          :site               => 'http://www.douban.com',
          :request_token_path => '/service/auth/request_token',
          :access_token_path  => '/service/auth/access_token',
          :authorize_path     => '/service/auth/authorize',
          :realm              => 'OmniAuth'
        }

        super(app, :douban, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:douban_user_id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash

        location = user_hash['location'] ? user_hash['location']['$t'] : nil
        image = user_hash['link'].find {|l| l['@rel'] == 'icon' }['@href']
        douban_url = user_hash['link'].find {|l| l['@rel'] == 'alternate' }['@href']
        {
          'username' => user_hash['db:uid']['$t'],
          'name' => user_hash['title']['$t'],
          'location' => location,
          'image' => image,
          'description' => user_hash['content']['$t'],
          'urls' => {
            'Douban' => douban_url
          }
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('http://api.douban.com/people/%40me?alt=json').body)
      end
    end
  end
end
