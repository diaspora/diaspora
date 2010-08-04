module Diaspora
  module OStatusGenerator
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
          objects.each {|x| xml << x.to_activity}
        else
          xml << objects.to_activity
        end
        xml
      end

      def self.footer
        <<-XML.strip
  </feed>
        XML
      end
    end
  end
end
