#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class StatusMessage < Post

  xml_name :status_message
  xml_accessor :message

  key :message, String
  validates_presence_of :message

  def to_activity
        <<-XML
  <entry>
    <title>#{self.message}</title>
    <link rel="alternate" type="text/html" href="#{person.url}status_messages/#{self.id}"/>
    <id>#{person.url}status_messages/#{self.id}</id>
    <published>#{self.created_at.xmlschema}</published>
    <updated>#{self.updated_at.xmlschema}</updated>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
  </entry>
        XML
  end

  def latest_hash
    { :text => message}
  end
end

