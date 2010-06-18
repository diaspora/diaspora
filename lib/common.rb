module Diaspora

  module Webhooks
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
          self.to_xml.to_s
        end
 
        def prep_many  
          "<post>#{self.to_xml.to_s}</post>"
        end

        def friends_with_permissions
           Friend.only(:url).map{|x| x = x.url + "/receive/"}
        end

        def self.build_xml_for(posts)
          xml = "<posts>"
          posts.each {|x| xml << x.prep_many}
          xml = xml + "</posts>"
        end
      end
    end
  end
end
