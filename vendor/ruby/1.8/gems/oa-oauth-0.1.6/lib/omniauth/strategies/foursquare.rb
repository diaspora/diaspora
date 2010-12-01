module OmniAuth
  module Strategies
    class Foursquare < OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :foursquare, consumer_key, consumer_secret,
                :site => 'http://foursquare.com')
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash
        
        {
          'nickname' => user_hash['twitter'],
          'first_name' => user_hash['firstname'],
          'last_name' => user_hash['lastname'],
          'email' => user_hash['email'],
          'name' => "#{user_hash['firstname']} #{user_hash['lastname']}".strip,
        # 'location' => user_hash['location'],
          'image' => user_hash['photo'],
        # 'description' => user_hash['description'],
          'phone' => user_hash['phone'],
          'urls' => {}
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('http://api.foursquare.com/v1/user.json').body)['user']
      end
    end
  end
end