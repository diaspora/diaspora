#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Taggable

  include ActionView::Helpers::TextHelper
  include PeopleHelper

  acts_as_taggable_on :tags
  extract_tags_from :raw_message

  validates_length_of :text, :maximum => 65535, :message => I18n.t('status_messages.too_long', :count => 65535)
  xml_name :status_message
  xml_attr :raw_message

  has_many :photos, :dependent => :destroy, :foreign_key => :status_message_guid, :primary_key => :guid

  # a StatusMessage is federated before its photos are so presence_of_content() fails erroneously if no text is present
  # therefore, we put the validation in a before_destory callback instead of a validation
  before_destroy :presence_of_content

  attr_accessible :text, :provider_display_name, :frame_name
  attr_accessor :oembed_url

  after_create :create_mentions
  after_create :queue_gather_oembed_data, :if => :contains_oembed_url_in_text?

  #scopes
  scope :where_person_is_mentioned, lambda { |person|
    joins(:mentions).where(:mentions => {:person_id => person.id})
  }

  def self.guids_for_author(person)
    Post.connection.select_values(Post.where(:author_id => person.id).select('posts.guid').to_sql)
  end

  def self.user_tag_stream(user, tag_ids)
    owned_or_visible_by_user(user).
      tag_stream(tag_ids)
  end

  def self.public_tag_stream(tag_ids)
    all_public.
      tag_stream(tag_ids)
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

  def attach_photos_by_ids(photo_ids)
    return [] unless photo_ids.present?
    self.photos << Photo.where(:id => photo_ids, :author_id => self.author_id).all
  end

  def nsfw
    self.raw_message.match(/#nsfw/i) || super
  end

  def formatted_message(opts={})
    return self.raw_message unless self.raw_message

    escaped_message = opts[:plain_text] ? self.raw_message : ERB::Util.h(self.raw_message)
    mentioned_message = self.format_mentions(escaped_message, opts)
    Diaspora::Taggable.format_tags(mentioned_message, opts.merge(:no_escape => true))
  end

  def format_mentions(text, opts = {})
    form_message = text.to_str.gsub(Mention::REGEX) do |matched_string|
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

  def mentioned_people_names
    self.mentioned_people.map(&:name).join(', ')
  end

  def create_mentions
    mentioned_people_from_string.each do |person|
      self.mentions.find_or_create_by_person_id(person.id)
    end
  end

  def mentions?(person)
    mentioned_people.include? person
  end

  def notify_person(person)
    self.mentions.where(:person_id => person.id).first.try(:notify_recipient)
  end

  def mentioned_people_from_string
    identifiers = self.raw_message.scan(Mention::REGEX).map do |match|
      match.last
    end
    identifiers.empty? ? [] : Person.where(:diaspora_handle => identifiers)
  end

  def after_dispatch(sender)
    self.update_and_dispatch_attached_photos(sender)
  end

  def update_and_dispatch_attached_photos(sender)
    if self.photos.any?
      self.photos.update_all(:public => self.public)
      self.photos.each do |photo|
        if photo.pending
          sender.add_to_streams(photo, self.aspects)
          sender.dispatch_post(photo)
        end
      end
      self.photos.update_all(:pending => false)
    end
  end

  def comment_email_subject
    formatted_message(:plain_text => true)
  end

  def first_photo_url(*args)
    photos.first.url(*args)
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
    self.oembed_url = urls.find{ |url| !TRUSTED_OEMBED_PROVIDERS.find(url).nil? }
  end

  protected
  def presence_of_content
    unless text_and_photos_blank?
      errors[:base] << "Cannot destory a StatusMessage with text and/or photos present"
    end
  end

  private
  def self.tag_stream(tag_ids)
    joins(:tags).where(:tags => {:id => tag_ids})
  end
end

