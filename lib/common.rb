module Diaspora
  module CommonFields
    def self.included(klass)
      klass.class_eval do
        include Mongoid::Document
        include ROXML
        include Mongoid::Timestamps

        xml_accessor :owner
        xml_accessor :snippet
        xml_accessor :source

        field :owner
        field :source
        field :snippet
      end
    end
  end

  module Hookey

class Curl
  def self.post(s)
    `curl -X POST -d #{s}`;;
  end
  
  def self.get(s)
    `curl -X GET #{s}`
  end
end


    def self.included(klass)
      
      klass.class_eval do
        require 'lib/message_handler'
        before_save :notify_friends
        
        def notify_friends
          m = MessageHandler.new

          xml = prep_webhook
          #friends_with_permissions.each{ |friend| puts friend; Curl.post( "\"" + xml + "\" " + friend) }
          m.add_post_request( friends_with_permissions, xml )
          m.process
        end
        
        def prep_webhook  
          self.to_xml.to_s.chomp
        end
        
        def friends_with_permissions
           #Friend.only(:url).map{|x| x = x.url + "/receive/"}
           googles = []
           5.times{ googles <<"http://google.com/"} #"http://localhost:4567/receive/"} #"http://google.com/"}
           googles
        end
      end
    end
  end
end
