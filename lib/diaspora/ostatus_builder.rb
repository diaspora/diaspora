#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

module Diaspora
  module OstatusBuilder

    def self.build(user)
      if @user = User.find_by_id(user.id)
        xml = ""
        xml << create_headers
        xml << create_endpoints
        xml << create_subject
        xml << create_body
        xml << create_footer
      else raise "Invalid user sent to builder" end
    end

    def self.create_headers
      <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:georss="http://www.georss.org/georss" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:media="http://purl.org/syndication/atommedia" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:statusnet="http://status.net/schema/api/1/">
      <generator uri="http://joindiaspora.com/">Diaspora</generator>
      <id>#{@user.username}/public</id>
      <title>Stream</title>
      <subtitle>its a stream</subtitle>
      <updated>#{Time.now.xmlschema}</updated>
      <author>
        <name>#{@user.real_name}</name>
        <uri>#{@user.public_url}</uri>
      </author>
      XML
    end

    def self.create_endpoints
      <<-XML
      <link href="#{APP_CONFIG[:pubsub_server]}" rel="hub"/>
      XML
    end

    def self.create_subject
      <<-XML
      <activity:subject>
      <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
      <id>#{@user.public_url}</id>
      <title>#{@user.real_name}</title>
      <link rel="alternative" type="text/html" href="#{@user.public_url}"/>
      </activity:subject>
      XML
    end

    def self.create_body
      @user.visible_posts(:public=>true).inject("") do |xml,curr|
        if curr.respond_to?(:to_activity)
          unless xml
            curr.to_activity 
          else
            xml + curr.to_activity 
          end
        end
      end
    end

    def self.create_footer
      <<-XML
      </feed>
      XML
    end

  end
end
