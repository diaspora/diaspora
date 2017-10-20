# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessage < Post
  include Diaspora::Taggable

  include Reference::Source
  include Reference::Target

  include PeopleHelper

  acts_as_taggable_on :tags
  extract_tags_from :text

  validates_length_of :text, :maximum => 65535, :message => proc {|p, v| I18n.t('status_messages.too_long', :count => 65535, :current_length => v[:value].length)}

  # don't allow creation of empty status messages
  validate :presence_of_content, on: :create

  has_many :photos, :dependent => :destroy, :foreign_key => :status_message_guid, :primary_key => :guid

  has_one :location
  has_one :poll, autosave: true, dependent: :destroy
  has_many :poll_participations, through: :poll

  attr_accessor :oembed_url
  attr_accessor :open_graph_url

  after_commit :queue_gather_oembed_data, :on => :create, :if => :contains_oembed_url_in_text?
  after_commit :queue_gather_open_graph_data, :on => :create, :if => :contains_open_graph_url_in_text?

  #scopes
  scope :where_person_is_mentioned, ->(person) {
    owned_or_visible_by_user(person.owner).joins(:mentions).where(mentions: {person_id: person.id})
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

  # Note: the next two methods can be safely removed once changes from #6818 are deployed on every pod
  # see StatusMessageCreationService#dispatch
  # Only includes those people, to whom we're going to send a federation entity
  # (and doesn't define exhaustive list of people who can receive it)
  def people_allowed_to_be_mentioned
    @aspects_ppl ||=
      if public?
        :all
      else
        Contact.joins(:aspect_memberships).where(aspect_memberships: {aspect: aspects}).distinct.pluck(:person_id)
      end
  end

  def filter_mentions
    return if people_allowed_to_be_mentioned == :all
    update(text: Diaspora::Mentionable.filter_people(text, people_allowed_to_be_mentioned))
  end

  private

  def presence_of_content
    errors[:base] << "Cannot create a StatusMessage without content" if text_and_photos_blank?
  end
end

