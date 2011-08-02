require 'multi_xml'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://api.linkedin.com',
          :request_token_path => '/uas/oauth/requestToken',
          :access_token_path => '/uas/oauth/accessToken',
          :authorize_path => '/uas/oauth/authorize',
          :scheme => :header
        }

        client_options[:authorize_path] = '/uas/oauth/authenticate' unless options[:sign_in] == false

        super(app, :linked_in, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        hash = user_hash(@access_token)

        OmniAuth::Utils.deep_merge(super, {
          'uid' => hash.delete('id'),
          'user_info' => hash
        })
      end

      def user_hash(access_token)
       person = MultiXml.parse(@access_token.get('/v1/people/~:(id,first-name,last-name,headline,member-url-resources,picture-url,location,public-profile-url)').body)['person']

        hash = {
          'id' => person['id'],
          'first_name' => person['first_name'],
          'last_name' => person['last_name'],
          'nickname' => person['public_profile_url'].split('/').last,
          'location' => person['location']['name'],
          'image' => person['picture_url'],
          'description' => person['headline'],
          'public_profile_url' => person['public_profile_url']
        }
        hash['urls']={}
        member_urls = person['member_url_resources']['member_url']
        if (!member_urls.nil?) and (!member_urls.empty?)
          [member_urls].flatten.each do |url|
            hash['urls']["#{url['name']}"]=url['url']
          end
        end
        hash['urls']['LinkedIn'] = person['public_profile_url']
        hash['name'] = "#{hash['first_name']} #{hash['last_name']}"
        hash
      end
    end
  end
end
