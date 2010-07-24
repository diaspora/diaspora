module Diaspora
  module Webhooks
    def self.included(klass)
      klass.class_eval do
          #require 'message_handler'
          @@queue = MessageHandler.new

          def notify_people
            if self.person_id == User.owner.id
              push_to(people_with_permissions)
            end
          end

          def subscribe_to_ostatus(feed_url)
            @@queue.add_subscription_request(feed_url)
            @@queue.process
          end

          def unsubscribe_from_ostatus(feed_url)
            @@queue.add_hub_unsubscribe_request(self.destination_url, self.callback_url+'hubbub', feed_url)
            @@queue.process
          end

          def push_to(recipients)
            @@queue.add_hub_notification(APP_CONFIG[:pubsub_server], User.owner.url + self.class.to_s.pluralize.underscore + '.atom')
            unless recipients.empty?
              recipients.map!{|x| x = x.url + "receive/"}  
              xml = self.class.build_xml_for(self)
              Rails.logger.info("Adding xml for #{self} to message queue to #{recipients}")
              @@queue.add_post_request( recipients, xml )
            end
            @@queue.process
          end

          def push_to_url(url)
            hook_url = url + "receive/"
            xml = self.class.build_xml_for(self)
            Rails.logger.info("Adding xml for #{self} to message queue to #{url}")
            @@queue.add_post_request( hook_url, xml )
            @@queue.process
          end

          def to_diaspora_xml
            "<post>#{self.to_xml.to_s}</post>"
          end

          def people_with_permissions
             Person.friends.all
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