require 'omniauth/oauth'
require 'multi_json'
require 'evernote'

module OmniAuth
  module Strategies
    #
    # Authenticate to Evernote via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Evernote, 'consumerkey', 'consumersecret'
    #
    class Evernote < OmniAuth::Strategies::OAuth
      # Initialize the Evernote strategy.
      #
      # @option options [Hash, {}] :client_options Options to be passed directly to the OAuth Consumer
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://www.evernote.com',
          :request_token_path => '/oauth',
          :access_token_path => '/oauth',
          :authorize_path => '/OAuth.action',
          :oauth_signature_method => 'PLAINTEXT'
        }

        super(app, :evernote, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data.id,
          'user_info' => user_info,
          'extra' => user_data
        })
      end

      def user_info
        {
          'name' => user_data.name,
          'nickname' => user_data.username,
        }
      end

      def user_data
        @user_data ||= begin
          user_store_url = consumer.site + '/edam/user'
          client = ::Evernote::Client.new(::Evernote::EDAM::UserStore::UserStore::Client, user_store_url, {})
          client.getUser(@access_token.token)
        end
      end
    end
  end
end
