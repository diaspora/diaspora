#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Socketable
  include YoutubeTitles
  require File.join(Rails.root, 'lib/youtube_titles')
  include ActionView::Helpers::TextHelper

  validates_length_of :message, :maximum => 1000, :message => "please make your status messages less than 1000 characters"
  xml_name :status_message
  xml_attr :message

  has_many :photos, :dependent => :destroy
  validate :message_or_photos_present?

  attr_accessible :message

  serialize :youtube_titles, Hash
  before_save do
    get_youtube_title message
  end

  def to_activity
    <<-XML
  <entry>
    <title>#{x(self.message)}</title>
    <link rel="alternate" type="text/html" href="#{person.url}status_messages/#{self.id}"/>
    <id>#{person.url}posts/#{self.id}</id>
    <published>#{self.created_at.xmlschema}</published>
    <updated>#{self.updated_at.xmlschema}</updated>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
  </entry>
      XML
  end

  def public_message(length, url = "")
    space_for_url = url.blank? ? 0 : (url.length + 1)
    truncated = truncate(self.message, :length => (length - space_for_url))
    truncated = "#{truncated} #{url}" unless url.blank?
    return truncated
  end

  protected

  def message_or_photos_present?
    if self.message.blank? && self.photos == []
      errors[:base] << 'Status message requires a message or at least one photo'
    end
  end
end

