#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Taggable

  include PeopleHelper

  acts_as_taggable_on :tags
  extract_tags_from :text

  validates_length_of :text, :maximum => 65535, :message => proc {|p, v| I18n.t('status_messages.too_long', :count => 65535, :current_length => v[:value].length)}

  # don't allow creation of empty status messages
  validate :presence_of_content, on: :create

  has_many :photos, :dependent => :destroy, :foreign_key => :status_message_guid, :primary_key => :guid

  has_one :location
  has_one :poll, autosave: true

  attr_accessor :oembed_url
  attr_accessor :open_graph_url

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
    owned_or_visible_by_user(user).tag_stream(tag_ids)
  end

  def self.public_tag_stream(tag_ids)
    all_public.tag_stream(tag_ids)
  end

  def self.tag_stream(tag_ids)
    joins(:taggings).where("taggings.tag_id IN (?)", tag_ids)
  end

  def nsfw
    text.try(:match, /#nsfw/i) || super
  end

  def message
    @message ||= Diaspora::MessageRenderer.new(text, mentioned_people: mentioned_people)
  end

  def mentioned_people
    if self.persisted?
      self.mentions.includes(:person => :profile).map{ |mention| mention.person }
    else
      Diaspora::Mentionable.people_from_string(text)
    end
  end

  ## TODO ----
  # don't put presentation logic in the model!
  def mentioned_people_names
    self.mentioned_people.map(&:name).join(', ')
  end
  ## ---- ----

  def create_mentions
    ppl = Diaspora::Mentionable.people_from_string(text)
    ppl.each do |person|
      self.mentions.find_or_create_by(person_id: person.id)
    end
  end

  def mentions?(person)
    mentioned_people.include? person
  end

  def comment_email_subject
    message.title
  end

  def first_photo_url(*args)
    photos.first.url(*args)
  end

  def text_and_photos_blank?
    text.blank? && photos.blank?
  end

  def queue_gather_oembed_data
    Workers::GatherOEmbedData.perform_async(self.id, self.oembed_url)
  end

  def queue_gather_open_graph_data
    Workers::GatherOpenGraphData.perform_async(self.id, self.open_graph_url)
  end

  def contains_oembed_url_in_text?
    urls = self.message.urls
    self.oembed_url = urls.find{ |url| !TRUSTED_OEMBED_PROVIDERS.find(url).nil? }
  end

  def contains_open_graph_url_in_text?
    return nil if self.contains_oembed_url_in_text?
    self.open_graph_url = self.message.urls[0]
  end

  def post_location
    {
      address: location.try(:address),
      lat:     location.try(:lat),
      lng:     location.try(:lng)
    }
  end

  def receive(recipient_user_ids)
    super(recipient_user_ids)

    photos.each {|photo| photo.receive(recipient_user_ids) }
  end

  private

  def presence_of_content
    errors[:base] << "Cannot create a StatusMessage without content" if text_and_photos_blank?
  end
end

