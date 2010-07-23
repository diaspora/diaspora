module Diaspora
  module OStatusParser
    def self.find_hub(xml)
      Nokogiri::HTML(xml).xpath('//link[@rel="hub"]').first.attribute("href").value
    end

    def self.process(xml)
      
      doc = Nokogiri::HTML(xml)
      parse_author(doc)
      puts ""
      parse_entry(doc)
    end

    def self.parse_author(doc)
      doc = Nokogiri::HTML(doc) if doc.is_a? String
      
      service = parse_service(doc)
      feed_url = parse_feed_url(doc)
      avatar_thumbnail = parse_avatar_thumbnail(doc)
      username = parse_username(doc)
      profile_url = parse_profile_url(doc)

      puts "the sender:"
      puts service
      puts feed_url
      puts avatar_thumbnail
      puts username
      puts profile_url
    end

    def self.parse_entry(doc)
      doc = Nokogiri::HTML(doc) if doc.is_a? String

      message = parse_message(doc)
      permalink = parse_permalink(doc)
      published_at = parse_published_at(doc)
      updated_at = parse_updated_at(doc)

      puts "the message"
      puts message
      puts permalink
      puts published_at
      puts updated_at
    end


    ##author###
    def self.parse_service(doc)
      doc.xpath('//generator').inner_html
    end

    def self.parse_feed_url(doc)
      doc.xpath('//id').first.inner_html
    end

    def self.parse_avatar_thumbnail(doc)
      doc.xpath('//logo').first.inner_html
    end

    def self.parse_username(doc)
      doc.xpath('//author/name').first.inner_html
    end

    def self.parse_profile_url(doc)
      doc.xpath('//author/uri').first.inner_html
    end


    #entry##
    def self.parse_message(doc)
      doc.xpath('//entry/title').first.inner_html
    end

    def self.parse_permalink(doc)
      doc.xpath('//entry/id').first.inner_html
    end

    def self.parse_published_at(doc)
      doc.xpath('//entry/published').first.inner_html
    end

    def self.parse_updated_at(doc)
      doc.xpath('//entry/updated').first.inner_html
    end 


    def self.parse_objects(xml)

    end
  end
  

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
          Rails.logger.info "Not a real type: #{object.to_s}"
        end
      end
      objects
    end

    def store_objects_from_xml(xml)
      objects = parse_objects_from_xml(xml)
      objects.each do |p|
        Rails.logger.info("Receiving object:\n#{p.inspect}")
        if p.is_a? Retraction
          p.perform
        elsif p.is_a? Request
          User.owner.receive_friend_request(p)
        #This line checks if the sender was in the database, among other things?
        elsif p.respond_to?(:person) && !(p.person.nil?) && !(p.person.is_a? User) #WTF
          Rails.logger.info("Saving object with success: #{p.save}")
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

        def subscribe_to_ostatus(feed_url)
          @@queue.add_subscription_request(feed_url)
          @@queue.process
        end

        def push_to(recipients)
          @@queue.add_hub_notification(APP_CONFIG[:pubsub_server], User.owner.url + self.class.to_s.pluralize.underscore + '.atom')
          
          unless recipients.empty?
            recipients.map!{|x| x = x.url + "receive/"}  
            xml = self.class.build_xml_for([self])
            Rails.logger.info("Adding xml for #{self} to message queue to #{recipients}")
            @@queue.add_post_request( recipients, xml )
          end
          @@queue.process
        end

        def push_to_url(url)
          hook_url = url + "receive/"
          xml = self.class.build_xml_for([self])
          Rails.logger.info("Adding xml for #{self} to message queue to #{url}")
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
        #this is retarded
        @@user = User.owner
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:georss="http://www.georss.org/georss" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:media="http://purl.org/syndication/atommedia" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:statusnet="http://status.net/schema/api/1/">
<generator uri="http://joindiaspora.com/">Diaspora</generator>
<id>#{current_url}</id>
<title>Stream</title>
<subtitle>its a stream </subtitle>
<updated>#{Time.now.xmlschema}</updated>
        XML
      end

      def self.author
        <<-XML
<author>
<name>#{@@user.real_name}</name>
<uri>#{@@user.url}</uri>
</author>
        XML
      end

      def self.endpoints
          <<-XML
 <link href="#{APP_CONFIG[:pubsub_server]}" rel="hub"/>
          XML
      end
      
      def self.subject
        <<-XML
<activity:subject>
<activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
<id>#{@@user.url}</id>
<title>#{@@user.real_name}</title>
<link rel="alternative" type="text/html" href="#{@@user.url}"/>
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
<activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
<title>#{status_message.message}</title>
<link rel="alternate" type="text/html" href="#{@@user.url}status_messages/#{status_message.id}"/>
<id>#{@@user.url}status_messages/#{status_message.id}</id>
<published>#{status_message.created_at.xmlschema}</published>
<updated>#{status_message.updated_at.xmlschema}</updated>
</entry>
        XML
      end

      def self.Bookmark_build_entry(bookmark)
        <<-XML
<entry>
<activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
<title>#{bookmark.title}</title>
<link rel="alternate" type="text/html" href="#{@@user.url}bookmarks/#{bookmark.id}"/>
<link rel="related" type="text/html" href="#{bookmark.link}"/>
<id>#{@@user.url}bookmarks/#{bookmark.id}</id>
<published>#{bookmark.created_at.xmlschema}</published>
<updated>#{bookmark.updated_at.xmlschema}</updated>
</entry>
        XML
      end


      def self.Blog_build_entry(blog)
        <<-XML
<entry>
<activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
<title>#{blog.title}</title>
<content>#{blog.body}</content>
<link rel="alternate" type="text/html" href="#{@@user.url}blogs/#{blog.id}"/>
<id>#{@@user.url}blogs/#{blog.id}</id>
<published>#{blog.created_at.xmlschema}</published>
<updated>#{blog.updated_at.xmlschema}</updated>
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
