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
  xml_attr :raw_message

  has_many :photos, :dependent => :destroy
  validate :message_or_photos_present?

  attr_accessible :message

  serialize :youtube_titles, Hash
  before_save do
    get_youtube_title message
  end

  def message(opts = {})
    self.formatted_message(opts)
  end

  def raw_message
    read_attribute(:message)
  end
  def raw_message=(text)
    write_attribute(:message, text)
  end

  def formatted_message(opts = {})
    return self.raw_message unless self.raw_message
    people = self.mentioned_people
    regex = /@\{([^;]+); ([^\}]+)\}/
    escaped_message = ERB::Util.h(raw_message)
    form_message = escaped_message.gsub(regex) do |matched_string|
      inner_captures = matched_string.match(regex).captures
      person = people.detect{ |p|
        p.diaspora_handle == inner_captures.last
      }

      if opts[:plain_text]
        person ? ERB::Util.h(person.name) : ERB::Util.h(inner_captures.first)
      else
        person ? "@<a href=\"/people/#{person.id}\" class=\"mention\">#{ERB::Util.h(person.name)}</a>" : ERB::Util.h(inner_captures.first)
      end
    end
    form_message
  end

  def mentioned_people
    if self.persisted?
      create_mentions if self.mentions.empty?
      self.mentions.includes(:person => :profile).map{ |mention| mention.person }
    else
      mentioned_people_from_string
    end
  end

  def create_mentions
    mentioned_people_from_string.each do |person|
      self.mentions.create(:person => person)
    end
  end

  def mentioned_people_from_string
    regex = /@\{([^;]+); ([^\}]+)\}/
    identifiers = self.raw_message.scan(regex).map do |match|
      match.last
    end
    identifiers.empty? ? [] : Person.where(:diaspora_handle => identifiers)
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

