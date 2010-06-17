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

    def self.included(klass)
      
      klass.class_eval do
        include EventQueue::MessageHandler
        before_save :notify_friends
        
        def notify_friends
          puts "hello"
          
          xml = prep_webhook
          #friends_with_permissions.each{ |friend| puts friend; Curl.post( "\"" + xml + "\" " + friend) }
          @@queue.add_post_request( friends_with_permissions, xml )
          @@queue.process
        end
        
        def prep_webhook  
          self.to_xml.to_s.chomp
        end
        
        def friends_with_permissions
           #Friend.only(:url).map{|x| x = x.url + "/receive/"}
           #googles = []
           #5.times{ googles <<"http://google.com/"} #"http://localhost:4567/receive/"} #"http://google.com/"}
           googles
        end
      end
    end
  end
end
