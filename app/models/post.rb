#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Guid

  include Diaspora::Likeable

  xml_attr :diaspora_handle
  xml_attr :provider_display_name
  xml_attr :public
  xml_attr :created_at

  has_many :comments, :dependent => :destroy

  has_many :aspect_visibilities
  has_many :aspects, :through => :aspect_visibilities

  has_many :post_visibilities
  has_many :contacts, :through => :post_visibilities
  has_many :mentions, :dependent => :destroy

  has_many :reshares, :class_name => "Reshare", :foreign_key => :root_guid, :primary_key => :guid
  has_many :resharers, :class_name => 'Person', :through => :reshares, :source => :author

  belongs_to :o_embed_cache

  belongs_to :author, :class_name => 'Person'
  
  validates :guid, :uniqueness => true

  after_create :cache_for_author

  #scopes
  scope :all_public, where(:public => true, :pending => false)
  scope :includes_for_a_stream,  includes(:o_embed_cache, {:author => :profile}, :mentions => {:person => :profile}) #note should include root and photos, but i think those are both on status_message

  def self.for_a_stream(max_time, order)
    by_max_time(max_time, order).
    includes_for_a_stream.
    where(:type => BaseStream::TYPES_OF_POST_IN_STREAM).
    limit(15)
  end

  def self.by_max_time(max_time, order='created_at')
    where("posts.#{order} < ?", max_time).order("posts.#{order} desc")
  end
  #############

  def diaspora_handle
    read_attribute(:diaspora_handle) || self.author.diaspora_handle
  end

  def user_refs
    if AspectVisibility.exists?(:post_id => self.id)
      self.post_visibilities.count + 1
    else
      self.post_visibilities.count
    end
  end

  def reshare_count
    @reshare_count ||= Post.where(:root_guid => self.guid).count
  end

  def diaspora_handle= nd
    self.author = Person.where(:diaspora_handle => nd).first
    write_attribute(:diaspora_handle, nd)
  end

  def self.diaspora_initialize params
    new_post = self.new params.to_hash
    new_post.author = params[:author]
    new_post.public = params[:public] if params[:public]
    new_post.pending = params[:pending] if params[:pending]
    new_post.diaspora_handle = new_post.author.diaspora_handle
    new_post
  end

  # @return Returns true if this Post will accept updates (i.e. updates to the caption of a photo).
  def mutable?
    false
  end

  # The list of people that should receive this Post.
  #
  # @param [User] user The context, or dispatching user.
  # @return [Array<Person>] The list of subscribers to this post
  def subscribers(user)
    if self.public?
      user.contact_people
    else
      user.people_in_aspects(user.aspects_with_post(self.id))
    end
  end

  def activity_streams?
    false
  end

  def triggers_caching?
    true
  end

  def comment_email_subject
    I18n.t('notifier.a_post_you_shared')
  end

  # @return [Array<Comment>]
  def last_three_comments
    self.comments.order('created_at DESC').limit(3).includes(:author => :profile).reverse
  end

  # @return [Integer]
  def update_comments_counter
    self.class.where(:id => self.id).
      update_all(:comments_count => self.comments.count)
  end

  # @return [Boolean]
  def cache_for_author
    if self.should_cache_for_author?
      cache = RedisCache.new(self.author.owner, 'created_at')
      cache.add(self.created_at.to_i, self.id)
    end
    true
  end

  # @return [Boolean]
  def should_cache_for_author?
    self.triggers_caching? && RedisCache.configured? &&
      RedisCache.acceptable_types.include?(self.type) && user = self.author.owner
  end


  # @param [User] user The user that is receiving this post.
  # @param [Person] person The person who dispatched this post to the
  # @return [void]
  def receive(user, person)
    #exists locally, but you dont know about it
    #does not exsist locally, and you dont know about it
    #exists_locally?
    #you know about it, and it is mutable
    #you know about it, and it is not mutable
    self.class.transaction do
      local_post = persisted_post

      if local_post && verify_persisted_post(local_post)
        self.receive_persisted(user, person, local_post)

      elsif !local_post
        self.receive_non_persisted(user, person)

      else
        Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason='update not from post owner' existing_post=#{self.id}")
        false
      end
    end
  end

  protected

  # @return [Post,void]
  def persisted_post
    self.class.where(:guid => self.guid).first
  end

  # @return [Boolean]
  def verify_persisted_post(persisted_post)
    persisted_post.author_id == self.author_id
  end

  def receive_persisted(user, person, local_post)
    known_post = user.find_visible_post_by_id(self.guid, :key => :guid)
    if known_post
      if known_post.mutable?
        known_post.update_attributes(self.attributes)
        true
      else
        Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason=immutable") #existing_post=#{known_post.id}")
        false
      end
    else
      user.contact_for(person).receive_post(local_post)
      user.notify_if_mentioned(local_post)
      Rails.logger.info("event=receive payload_type=#{self.class} update=true status=complete sender=#{self.diaspora_handle}") #existing_post=#{local_post.id}")
      true
    end
  end

  def receive_non_persisted(user, person)
    if self.save
      user.contact_for(person).receive_post(self)
      user.notify_if_mentioned(self)
      Rails.logger.info("event=receive payload_type=#{self.class} update=false status=complete sender=#{self.diaspora_handle}")
      true
    else
      Rails.logger.info("event=receive payload_type=#{self.class} update=false status=abort sender=#{self.diaspora_handle} reason=#{self.errors.full_messages}")
      false
    end
  end
end
