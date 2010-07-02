module Diaspora
  module XMLParser

    def parse_owner_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      email = doc.xpath("//person/email").text.to_s
      Friend.where(:email => email).first
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
          object.person =  parse_owner_from_xml post.to_s #if object.is_a? Post  
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
        #This line checks if the sender was in the database, among other things?
        p.save if p.respond_to?(:person) && !(p.person.nil?) #WTF
        #p.save if p.respond_to?(:person) && !(p.person == nil) #WTF
      end
    end
  end

  module Webhooks
    def self.included(klass)
      klass.class_eval do
        @@queue = MessageHandler.new
        
        def notify_friends
          if self.person_id == User.first.id
            push_to(friends_with_permissions)
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


        def prep_webhook
          "<post>#{self.to_xml.to_s}</post>"
        end

        def friends_with_permissions
           Friend.all
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
