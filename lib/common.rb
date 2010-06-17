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
        before_save :notify_friends

        @@queue = MessageHandler.new
        
        def notify_friends
          xml = prep_webhook
          @@queue.add_post_request( friends_with_permissions, xml )
          @@queue.process
        end
        
        def prep_webhook  
          self.to_xml.to_s.chomp
        end
        
        def friends_with_permissions
           Friend.only(:url).map{|x| x = x.url + "/receive/"}
        end
      end
    end
  end
end
