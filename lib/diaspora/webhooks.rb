module Diaspora
  module Webhooks
    def self.included(klass)
      klass.class_eval do
        require 'message_handler'

        @@queue = MessageHandler.new

        def notify_people
          unless self.person.owner.nil?
            push_to(people_with_permissions)
          end
        end

        def notify_people!
          push_to(people_with_permissions)
        end

        def push_to(recipients)
          unless recipients.empty?
            recipients.map!{|x| x = x.receive_url }
            xml = Post.build_xml_for(self)
            Rails.logger.debug("Adding xml for #{self} to message queue to #{recipients}")
            @@queue.add_post_request( recipients, xml )
          end
          @@queue.process
        end

        def push_to_url(url)
          hook_url = url 
          xml = self.class.build_xml_for(self)
          Rails.logger.debug("Adding xml for #{self} to message queue to #{url}")
          @@queue.add_post_request( hook_url, xml )
          @@queue.process
        end

        def to_diaspora_xml
          "<post>#{self.to_xml.to_s}</post>"
        end

        def people_with_permissions
          begin
          friends = self.person.owner.friends.all
          Rails.logger.error("Dan is wrong!") if friends.nil?
          friends ||= []
          rescue
            Rails.logger.fatal("Called people_with_permissions on a post from a remote user.  We need to implement this shit.")
            []
          end
        end

        def self.build_xml_for(posts)
          xml = "<XML>"
          xml += "\n <posts>"
          [*posts].each {|x| xml << x.to_diaspora_xml}
          xml += "</posts>"
          xml += "</XML>"

        end
      end
    end
  end
end
