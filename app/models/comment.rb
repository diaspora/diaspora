#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Comment < ActiveRecord::Base

  include Diaspora::Federated::Base

  include Diaspora::Guid
  include Diaspora::Relayable

  include Diaspora::Taggable
  include Diaspora::Likeable

  acts_as_taggable_on :tags
  extract_tags_from :text
  before_create :build_tags

  xml_attr :text
  xml_attr :diaspora_handle

  #Don't name it remote_create_at, otherwise it won't work due to some mysterious reasons
  xml_attr :remote_created

  belongs_to :commentable, :touch => true, :polymorphic => true
  alias_attribute :post, :commentable
  belongs_to :author, :class_name => 'Person'

  delegate :name, to: :author, prefix: true
  delegate :comment_email_subject, to: :parent
  delegate :author_name, to: :parent, prefix: true

  validates :text, :presence => true, :length => {:maximum => 65535}
  validates :parent, :presence => true #should be in relayable (pending on fixing Message)

  scope :including_author, -> { includes(:author => :profile) }
  scope :for_a_stream,  -> { including_author.merge(order('created_at ASC')) }

  before_save do
    self.text.strip! unless self.text.nil?
  end

  after_save do
    self.post.touch
  end

  after_commit :on => :create do
    self.parent.update_comments_counter
  end

  after_destroy do
    self.parent.update_comments_counter
    participation = author.participations.where(target_id: post.id).first
    participation.unparticipate! if participation.present?
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def remote_created
    Time.zone.parse(self.created_at.to_s).to_i.to_s unless(self.created_at.nil?)
  end

  def remote_created= date
    self.created_at = Time.at(date.to_i).utc.to_datetime unless date.blank?
  end

  def notification_type(user, person)
    if self.post.author == user.person
      return Notifications::CommentOnPost
    elsif user.participations.where(:target_id => self.post).exists? && self.author_id != user.person.id
      return Notifications::AlsoCommented
    else
      return false
    end
  end

  def parent_class
    Post
  end

  def parent
    self.post
  end

  def parent= parent
    self.post = parent
  end

  def message
    @message ||= Diaspora::MessageRenderer.new text
  end

  def text= text
     self[:text] = text.to_s.strip #to_s if for nil, for whatever reason
  end

  class Generator < Federated::Generator
    def self.federated_class
      Comment
    end

    def initialize(person, target, text)
      @text = text
      super(person, target)
    end

    def relayable_options
      {:post => @target, :text => @text}
    end
  end
end
