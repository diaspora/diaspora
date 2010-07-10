module Diaspora
  module XMLParser

    def parse_owner_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      email = doc.xpath("//person/email").text.to_s
      Person.where(:email => email).first
    end

    def parse_body_contents_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      doc.xpath("/XML/posts/post")
    end

    def parse_objects_from_xml(xml)
      objects = []
      body = parse_body_contents_from_xml(xml)
      body.children.each do |post|
        begin
          object = post.name.camelize.constantize.from_xml post.to_s
          object.person =  parse_owner_from_xml post.to_s if object.respond_to? :person  
          objects << object 
        rescue
          puts "Not a real type: #{object.to_s}"
        end
      end
      objects
    end

    def store_objects_from_xml(xml)
      objects = parse_objects_from_xml(xml)
      objects.each do |p|
        if p.is_a? Retraction
          p.perform
        elsif p.is_a? Request
          User.first.receive_friend_request(p)
        #This line checks if the sender was in the database, among other things?
        elsif p.respond_to?(:person) && !(p.person.nil?) && !(p.person.is_a? User) #WTF
          p.save 
        end
        #p.save if p.respond_to?(:person) && !(p.person == nil) #WTF
      end
    end
  end

  module Webhooks
    def self.included(klass)
      klass.class_eval do
        include ROXML
        require 'message_handler'
        @@queue = MessageHandler.new

        def notify_people
          if self.person_id == User.first.id
            push_to(people_with_permissions)
          end
        end

        def push_to(recipients)
          unless recipients.empty?
            recipients.map!{|x| x = x.url + "receive/"}  
            xml = self.class.build_xml_for([self])
            @@queue.add_post_request( recipients, xml )
            @@queue.process
          end
        end

        def push_to_url(url)
          hook_url = url + "receive/"
          xml = self.class.build_xml_for([self])
          @@queue.add_post_request( [hook_url], xml )
          @@queue.process
        end

        def prep_webhook
          "<post>#{self.to_xml.to_s}</post>"
        end

        def people_with_permissions
           Person.friends.all
        end

        def self.build_xml_for(posts)
          xml = "<XML>"
          xml += "\n <posts>"
          posts.each {|x| xml << x.prep_webhook}
          xml += "</posts>"
          xml += "</XML>"
        end

      end
    end
  end
end
