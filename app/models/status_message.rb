#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Socketable
  include Diaspora::Taggable

  include YoutubeTitles
  require File.join(Rails.root, 'lib/youtube_titles')
  include ActionView::Helpers::TextHelper
  include PeopleHelper

  acts_as_taggable_on :tags
  extract_tags_from :raw_message

  validates_length_of :text, :maximum => 10000, :message => I18n.t('status_messages.too_long', :count => 10000)
  xml_name :status_message
  xml_attr :raw_message

  has_many :photos, :dependent => :destroy, :foreign_key => :status_message_guid, :primary_key => :guid
  validate :presence_of_content

  attr_accessible :text, :provider_display_name
  attr_accessor :oembed_url
  serialize :youtube_titles, Hash

  after_create :create_mentions

  after_create :queue_gather_oembed_data, :if => :contains_oembed_url_in_text?

  #scopes
  scope :where_person_is_mentioned, lambda{|person| joins(:mentions).where(:mentions => {:person_id => person.id})}

  def self.owned_or_visible_by_user(user)
    joins("LEFT OUTER JOIN post_visibilities ON post_visibilities.post_id = posts.id").
    joins("LEFT OUTER JOIN contacts ON contacts.id = post_visibilities.contact_id").
    where(Contact.arel_table[:user_id].eq(user.id).or(
      StatusMessage.arel_table[:public].eq(true).or(
        StatusMessage.arel_table[:author_id].eq(user.person.id)
      )
    )).select('DISTINCT posts.*')
  end

  def self.tag_stream(user, tag_array, max_time, order)
    owned_or_visible_by_user(user).
      joins(:tags).where(:tags => {:name => tag_array}).
      for_a_stream(max_time, order)
  end

  def text(opts = {})
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
    Diaspora::Taggable.format_tags(mentioned_message, opts.merge(:no_escape => true))
  end

  def format_mentions(text, opts = {})
    regex = /@\{([^;]+); ([^\}]+)\}/
    form_message = text.to_str.gsub(regex) do |matched_string|
      people = self.mentioned_people
      person = people.detect{ |p|
        p.diaspora_handle == $~[2] unless p.nil?
      }

      if opts[:plain_text]
        person ? ERB::Util.h(person.name) : ERB::Util.h($~[1])
      else
        person ? person_link(person, :class => 'mention hovercardable') : ERB::Util.h($~[1])
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

  def to_activity(opts={})
    author = opts[:author] || self.author #Use an already loaded author if passed in.
    <<-XML
  <entry>
    <title>#{x(self.formatted_message(:plain_text => true))}</title>
    <content>#{x(self.formatted_message(:plain_text => true))}</content>
    <link rel="alternate" type="text/html" href="#{author.url}p/#{self.id}"/>
    <id>#{author.url}p/#{self.id}</id>
    <published>#{self.created_at.xmlschema}</published>
    <updated>#{self.updated_at.xmlschema}</updated>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
  </entry>
    XML
  end

  def socket_to_user(user_or_id, opts={})
    unless opts[:aspect_ids]
      user_id = user_or_id.instance_of?(Fixnum) ? user_or_id : user_or_id.id
      aspect_ids = AspectMembership.connection.select_values(
        AspectMembership.joins(:contact).where(:contacts => {:user_id => user_id, :person_id => self.author_id}).select('aspect_memberships.aspect_id').to_sql
      )
      opts.merge!(:aspect_ids => aspect_ids)
    end
    super(user_or_id, opts)
  end

  def after_dispatch sender
    unless self.photos.empty?
      self.photos.update_all(:pending => false, :public => self.public)
      for photo in self.photos
        if photo.pending
          sender.add_to_streams(photo, self.aspects)
          sender.dispatch_post(photo)
        end
      end
    end
  end

  def comment_email_subject
    formatted_message(:plain_text => true)
  end

  def text_and_photos_blank?
    self.text.blank? && self.photos.blank?
  end

  def queue_gather_oembed_data
    Resque.enqueue(Jobs::GatherOEmbedData, self.id, self.oembed_url)
  end 
  
  def contains_oembed_url_in_text?
    require 'uri'
    urls = URI.extract(self.raw_message, ['http', 'https'])
    self.oembed_url = urls.find{|url| ENDPOINT_HOSTS_STRING.match(URI.parse(url).host)}
  end

  protected

  def presence_of_content
    if text_and_photos_blank?
      errors[:base] << 'Status message requires a message or at least one photo'
    end
  end
end

