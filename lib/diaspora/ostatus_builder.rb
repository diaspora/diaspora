#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora

  class Director
    def initialize
      @structure = [:create_headers, :create_endpoints, :create_subject,
                    :create_body, :create_footer]
    end

    def build(builder)
      @structure.inject("") do |xml, method|
        xml << builder.send(method) if builder.respond_to? method
      end
    end
  end


  class OstatusBuilder
    include Diaspora::Webhooks

    def initialize(user, posts)
      @user = user
      @posts = posts
    end

    def create_headers
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:georss="http://www.georss.org/georss" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:media="http://purl.org/syndication/atommedia" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:statusnet="http://status.net/schema/api/1/">
<generator uri="#{AppConfig[:pod_url]}">Diaspora</generator>
<id>#{@user.public_url}.atom</id>
<title>#{x(@user.name)}'s Public Feed</title>
<subtitle>Updates from #{x(@user.name)} on Diaspora</subtitle>
<logo>#{@user.person.profile.image_url(:thumb_small)}</logo>
<updated>#{Time.now.xmlschema}</updated>
      XML
    end

    def create_subject
      <<-XML
<author>
  <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
  <name>#{x(@user.name)}</name>
  <uri>"#{AppConfig[:pod_url]}/people/#{@user.person.id}"</uri>
  <link href="#{@user.public_url}" rel="alternative" type="text/html"/>
  <poco:preferredUsername>#{x(@user.username)}</poco:preferredUsername>
  <poco:displayName>#{x(@user.person.name)}</poco:displayName>
  <link rel="avatar" type="image/jpeg" media:width="100" media:height="100" href="#{@user.profile.image_url}"/>
</author>
      XML
    end

    def create_endpoints
      <<-XML
<link href="#{AppConfig[:pubsub_server]}" rel="hub"/>
<link href="#{@user.public_url}.atom" rel="self" type="application/atom+xml"/>
      XML
    end

    def create_body
      @posts.inject("") do |xml,curr|
        if curr.respond_to?(:to_activity)
          unless xml
            curr.to_activity
          else
            xml + curr.to_activity
          end
        else
          xml
        end
      end
    end

    def create_footer
      <<-XML
</feed>
      XML
    end
  end
end
