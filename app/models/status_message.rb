#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Taggable

  include PeopleHelper

  acts_as_taggable_on :tags
  extract_tags_from :raw_message

  validates_length_of :text, :maximum => 65535, :message => I18n.t('status_messages.too_long', :count => 65535)

  # don't allow creation of empty status messages
  validate :presence_of_content, on: :create, if: proc { |sm| sm.author.local? }

  xml_name :status_message
  xml_attr :raw_message
  xml_attr :photos, :as => [Photo]
  xml_attr :location, :as => Location
  xml_attr :poll, :as => Poll

  has_many :photos, :dependent => :destroy, :foreign_key => :status_message_guid, :primary_key => :guid

  has_one :location
  has_one :poll, autosave: true


  # a StatusMessage is federated before its photos are so presence_of_content() fails erroneously if no text is present
  # therefore, we put the validation in a before_destory callback instead of a validation
  before_destroy :absence_of_content

  attr_accessor :oembed_url
  attr_accessor :open_graph_url

  before_create :filter_mentions
  after_create :create_mentions
  after_commit :queue_gather_oembed_data, :on => :create, :if => :contains_oembed_url_in_text?
  after_commit :queue_gather_open_graph_data, :on => :create, :if => :contains_open_graph_url_in_text?

  #scopes
  scope :where_person_is_mentioned, ->(person) {
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

  def raw_message
    read_attribute(:text)
  end

  def raw_message=(text)
    write_attribute(:text, text)
  end

  def attach_photos_by_ids(photo_ids)
    return [] unless photo_ids.present?
    self.photos << Photo.where(:id => photo_ids, :author_id => self.author_id)
  end

  def nsfw
    self.raw_message.match(/#nsfw/i) || super
  end

  def message
    @message ||= Diaspora::MessageRenderer.new raw_message, mentioned_people: mentioned_people
  end

  def mentioned_people
    if self.persisted?
      create_mentions if self.mentions.empty?
      self.mentions.includes(:person => :profile).map{ |mention| mention.person }
    else
      Diaspora::Mentionable.people_from_string(self.raw_message)
    end
  end

  ## TODO ----
  # don't put presentation logic in the model!
  def mentioned_people_names
    self.mentioned_people.map(&:name).join(', ')
  end
  ## ---- ----

  def create_mentions
    ppl = Diaspora::Mentionable.people_from_string(self.raw_message)
    ppl.each do |person|
      self.mentions.find_or_create_by(person_id: person.id)
    end
  end

  def mentions?(person)
    mentioned_people.include? person
  end

  def notify_person(person)
    self.mentions.where(:person_id => person.id).first.try(:notify_recipient)
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
    message.title length: 70
  end

  def first_photo_url(*args)
    photos.first.url(*args)
  end

  def text_and_photos_blank?
    self.raw_message.blank? && self.photos.blank?
  end

  def queue_gather_oembed_data
    Workers::GatherOEmbedData.perform_async(self.id, self.oembed_url)
  end

  def queue_gather_open_graph_data
    Workers::GatherOpenGraphData.perform_async(self.id, self.open_graph_url)
  end

  def contains_oembed_url_in_text?
    urls = URI.extract(self.raw_message, ['http', 'https'])
    self.oembed_url = urls.find{ |url| !TRUSTED_OEMBED_PROVIDERS.find(url).nil? }
  end

  def contains_open_graph_url_in_text?
    return nil if self.contains_oembed_url_in_text?
    self.open_graph_url = URI.extract(self.raw_message, ['http', 'https'])[0]
  end

  def address
    location.try(:address)
  end

  protected
  def presence_of_content
    if text_and_photos_blank?
      errors[:base] << "Cannot create a StatusMessage without content"
    end
  end

  def absence_of_content
    unless text_and_photos_blank?
      errors[:base] << "Cannot destory a StatusMessage with text and/or photos present"
    end
  end

  def filter_mentions
    return if self.public? || self.aspects.empty?

    author_usr = self.author.try(:owner)
    aspect_ids = self.aspects.map(&:id)

    self.raw_message = Diaspora::Mentionable.filter_for_aspects(self.raw_message, author_usr, *aspect_ids)
  end

  private
  def self.tag_stream(tag_ids)
    joins(:taggings).where('taggings.tag_id IN (?)', tag_ids)
  end
end

