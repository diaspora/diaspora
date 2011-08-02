# Based heavily on the Google strategy, monkeypatch and all

require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to YouTube via OAuth and retrieve basic user info.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::YouTube, 'consumerkey', 'consumersecret'
    #
    class YouTube < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://www.google.com',
          :request_token_path => '/accounts/OAuthGetRequestToken',
          :access_token_path => '/accounts/OAuthGetAccessToken',
          :authorize_path => '/accounts/OAuthAuthorizeToken'
        }

        super(app, :you_tube, consumer_key, consumer_secret, client_options, options)
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
        entry = user_hash['entry']
        {
          'uid' => entry['id']['$t'],
          'nickname' => entry['author'].first['name']['$t'],
          'first_name' => entry['yt$firstName'] && entry['yt$firstName']['$t'],
          'last_name' => entry['yt$lastName'] && entry['yt$lastName']['$t'],
          'image' => entry['media$thumbnail'] && entry['media$thumbnail']['url'],
          'description' => entry['yt$description'] && entry['yt$description']['$t'],
          'location' => entry['yt$location'] && entry['yt$location']['$t']
        }
      end

      def user_hash
        # YouTube treats 'default' as the currently logged-in user
        # via http://apiblog.youtube.com/2010/11/update-to-clientlogin-url.html
        @user_hash ||= MultiJson.decode(@access_token.get("http://gdata.youtube.com/feeds/api/users/default?alt=json").body)
      end

      # Monkeypatch consumer.get_request_token but specify YouTube scope rather than Google Contacts
      # TODO this is an easy patch to the underlying OAuth strategy a la OAuth2
      def request_phase
        request_token = consumer.get_request_token({:oauth_callback => callback_url}, {:scope => 'http://gdata.youtube.com'})
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => request_token.callback_confirmed?, 'request_token' => request_token.token, 'request_secret' => request_token.secret}
        r = Rack::Response.new

        if request_token.callback_confirmed?
          r.redirect(request_token.authorize_url)
        else
          r.redirect(request_token.authorize_url(:oauth_callback => callback_url))
        end

        r.finish
      end
    end
  end
end
