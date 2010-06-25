module Diaspora
  module Webhooks
  include ApplicationHelper
    def self.included(klass)
      klass.class_eval do
      after_save :notify_friends
        @@queue = MessageHandler.new
        
        def notify_friends
          if mine? self
            xml = Post.build_xml_for(self)
            @@queue.add_post_request( friends_with_permissions, xml )
            @@queue.process
          end
        end
 
        def prep_webhook
          "<post>#{self.to_xml.to_s}</post>"
        end

        def friends_with_permissions
           Friend.all.map{|x| x = x.url + "receive/"}
        end

        def self.build_xml_for(posts)
          xml = "<XML>"
          xml += Post.generate_header
          xml += "<posts>"
          posts.each {|x| xml << x.prep_webhook}
          xml += "</posts>"
          xml += "</XML>"
        end


        def self.generate_header
          "<head>
            <sender>
              <email>#{User.first.email}</email>
            </sender>
          </head>"
        end
      end
    end
  end
end
