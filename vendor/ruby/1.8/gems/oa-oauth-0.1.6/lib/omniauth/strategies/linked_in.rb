require 'nokogiri'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :linked_in, consumer_key, consumer_secret,
                :site => 'https://api.linkedin.com',
                :request_token_path => '/uas/oauth/requestToken',
                :access_token_path => '/uas/oauth/accessToken',
                :authorize_path => '/uas/oauth/authorize',
                :scheme => :header)
      end
      
      def auth_hash
        hash = user_hash(@access_token)
        
        OmniAuth::Utils.deep_merge(super, {
          'uid' => hash.delete('id'),
          'user_info' => hash
        })
      end
      
      def user_hash(access_token)
        person = Nokogiri::XML::Document.parse(@access_token.get('/v1/people/~:(id,first-name,last-name,headline,member-url-resources,picture-url,location)').body).xpath('person')
        
        hash = {
          'id' => person.xpath('id').text,
          'first_name' => person.xpath('first-name').text,
          'last_name' => person.xpath('last-name').text,
          'location' => person.xpath('location/name').text,
          'image' => person.xpath('picture-url').text,
          'description' => person.xpath('headline').text,
          'urls' => person.css('member-url-resources member-url').inject({}) do |h,element|
            h[element.xpath('name').text] = element.xpath('url').text
            h
          end
        }
        
        hash[:name] = "#{hash['first_name']} #{hash['last_name']}"
        hash
      end
    end
  end
end
