#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Socketable
  
  validates_length_of :message, :maximum => 1000, :message => "please make your status messages less than 1000 characters"
  xml_name :status_message
  xml_reader :message

  key :message, String
  many :photos, :class => Photo, :foreign_key => :status_message_id
  validate :message_or_photos_present?

  attr_accessible :message

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

  protected

  def message_or_photos_present?
    unless !self.message.blank? || self.photos.count > 0
      errors[:base] << 'Status message requires a message or at least one photo'
    end
  end

end

