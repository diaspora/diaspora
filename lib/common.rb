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
          User.owner.receive_friend_request(p)
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
          if self.person_id == User.owner.id
            push_to(people_with_permissions)
          end
        end

        def push_to(recipients)
          unless recipients.empty?
            recipients.map!{|x| x = x.url + "receive/"}  
            xml = self.class.build_xml_for([self])
            @@queue.add_post_request( recipients, xml )

            @@queue.add_hub_notification('http://pubsubhubbub.appspot.com/publish', User.owner.url + self.class.to_s.pluralize.underscore + '.atom' )
            
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

  module XML

    OWNER = User.owner

    def self.generate(opts= {})
      xml = Generate::headers(opts[:current_url])
      xml << Generate::author
      xml << Generate::endpoints
      xml << Generate::subject
      xml << Generate::entries(opts[:objects])
      xml << Generate::footer
    end

    module Generate
      def self.headers(current_url)
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:georss="http://www.georss.org/georss" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:media="http://purl.org/syndication/atommedia" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:statusnet="http://status.net/schema/api/1/">
<generator uri="#{OWNER.url}">Diaspora</generator>
<id>#{current_url}</id>
<title>Stream</title>
<subtitle>its a stream </subtitle>
<updated>#{Time.now.xmlschema}</updated>
        XML
      end

      def self.author
        <<-XML
<author>
<name>#{OWNER.real_name}</name>
<uri>#{OWNER.url}</uri>
</author>
        XML
      end

      def self.endpoints
          <<-XML
 <link href="http://pubsubhubbub.appspot.com/" rel="hub"/>
          XML
      end
      
      def self.subject
        <<-XML
<activity:subject>
<activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
<id>#{OWNER.url}</id>
<title>#{OWNER.real_name}</title>
<link rel="alternative" type="text/html" href="#{OWNER.url}"/>
</activity:subject>
        XML
      end

      def self.entries(objects)
        xml = ""
        if objects.respond_to? :each
          objects.each {|x| xml << self.entry(x)}
        else
          xml << self.entry(objects)
        end
        xml
      end

      def self.entry(object)
        eval "#{object.class}_build_entry(object)"
      end

      def self.StatusMessage_build_entry(status_message)
        <<-XML
<entry>
<title>#{status_message.message}</title>
<link rel="alternate" type="text/html" href="#{OWNER.url}status_messages/#{status_message.id}"/>
<id>#{OWNER.url}status_messages/#{status_message.id}</id>
<published>#{status_message.created_at.xmlschema}</published>
<updated>#{status_message.updated_at.xmlschema}</updated>
</entry>
        XML
      end

      def self.footer
        <<-XML.strip
</feed>
        XML
      end
    end
  end
end
