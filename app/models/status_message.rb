#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Socketable
  include YoutubeTitles
  require File.join(Rails.root, 'lib/youtube_titles')
  include ActionView::Helpers::TextHelper

  acts_as_taggable_on :tags

  validates_length_of :message, :maximum => 1000, :text => "please make your status messages less than 1000 characters"
  xml_name :status_message
  xml_attr :raw_message

  has_many :photos, :dependent => :destroy
  validate :message_or_photos_present?

  attr_accessible :text

  serialize :youtube_titles, Hash
  before_save do
    get_youtube_title text
  end

  before_create :build_tags

  def message(opts = {})
    self.formatted_message(opts)
  end

  def raw_message
    read_attribute(:text)
  end
  def raw_message=(text)
    write_attribute(:text, text)
  end

  def formatted_message(opts={})
    return self.raw_message unless self.raw_message

    escaped_message = opts[:plain_text] ? self.raw_message: ERB::Util.h(self.raw_message)
    mentioned_message = self.format_mentions(escaped_message, opts)
    self.format_tags(mentioned_message, opts)
  end

  def format_tags(text, opts={})
    return text if opts[:plain_text]
    regex = /(^|\s)#(\w+)/
    form_message = text.gsub(regex) do |matched_string|
      "#{$~[1]}<a href=\"/p?tag=#{$~[2]}\" class=\"tag\">##{ERB::Util.h($~[2])}</a>"
    end
    form_message
  end

  def format_mentions(text, opts = {})
    people = self.mentioned_people
    regex = /@\{([^;]+); ([^\}]+)\}/
    form_message = text.gsub(regex) do |matched_string|
      person = people.detect{ |p|
        p.diaspora_handle == $~[2] unless p.nil?
      }

      if opts[:plain_text]
        person ? ERB::Util.h(person.name) : ERB::Util.h($~[1])
      else
        person ? "<a href=\"/people/#{person.id}\" class=\"mention\">@#{ERB::Util.h(person.name)}</a>" : ERB::Util.h($~[1])
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

  def mentions?(person)
    mentioned_people.include? person
  end

  def notify_person(person)
    self.mentions.where(:person_id => person.id).first.try(:notify_recipient)
  end

  def mentioned_people_from_string
    regex = /@\{([^;]+); ([^\}]+)\}/
    identifiers = self.raw_message.scan(regex).map do |match|
      match.last
    end
    identifiers.empty? ? [] : Person.where(:diaspora_handle => identifiers)
  end

  def build_tags
    self.tag_list = tag_strings
  end

  def tag_strings
    regex = /(?:^|\s)#(\w+)/
    matches = self.raw_message.scan(regex).map do |match|
      match.last
    end
    unique_matches = matches.inject(Hash.new) do |h,element|
      h[element.downcase] = element unless h[element.downcase]
      h
    end
    unique_matches.values
  end

  def to_activity
    <<-XML
  <entry>
    <title>#{x(self.formatted_message(:plain_text => true))}</title>
    <content>#{x(self.formatted_message(:plain_text => true))}</content>
    <link rel="alternate" type="text/html" href="#{self.author.url}p/#{self.id}"/>
    <id>#{self.author.url}posts/#{self.id}</id>
    <published>#{self.created_at.xmlschema}</published>
    <updated>#{self.updated_at.xmlschema}</updated>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
  </entry>
      XML
  end

  protected

  def message_or_photos_present?
    if self.text.blank? && self.photos == []
      errors[:base] << 'Status message requires a message or at least one photo'
    end
  end
end

