require 'multi_xml'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class Goodreads < OmniAuth::Strategies::OAuth

      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'http://www.goodreads.com',
        }
        @consumer_key = consumer_key
        super(app, :goodreads, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        hash = user_hash(@access_token)

        OmniAuth::Utils.deep_merge(super, {
          'uid' => hash.delete('id'),
          'user_info' => hash
        })
      end

      def user_hash(access_token)
        authenticated_user = MultiXml.parse(@access_token.get('/api/auth_user').body)
        id = authenticated_user.xpath('GoodreadsResponse/user').attribute('id').value.to_i
        response_doc = MultiXml.parse(open("http://www.goodreads.com/user/show/#{id}.xml?key=#{@consumer_key}").read)
        user = response_doc.xpath('GoodreadsResponse/user')

        hash = {
          'id' => id,
          'name' => user.xpath('name').text,
          'user_name' => user.xpath('user_name').text,
          'image_url' => user.xpath('image_url').text,
          'about' => user.xpath('about').text,
          'location' => user.xpath('location').text,
          'website' => user.xpath('website').text,
        }
      end
    end
  end
end

