# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Comment < ApplicationRecord

  include Diaspora::Federated::Base
  include Diaspora::Fields::Guid
  include Diaspora::Fields::Author
  include Diaspora::Relayable

  include Diaspora::Taggable
  include Diaspora::Likeable
  include Diaspora::MentionsContainer
  include Reference::Source

  acts_as_taggable_on :tags
  extract_tags_from :text
  before_create :build_tags

  belongs_to :commentable, :touch => true, :polymorphic => true
  alias_attribute :post, :commentable
  alias_attribute :parent, :commentable

  delegate :name, to: :author, prefix: true
  delegate :comment_email_subject, to: :parent
  delegate :author_name, to: :parent, prefix: true

  validates :text, :presence => true, :length => {:maximum => 65535}

  has_many :reports, as: :item

  has_one :signature, class_name: "CommentSignature", dependent: :delete

  scope :including_author, -> { includes(:author => :profile) }
  scope :for_a_stream,  -> { including_author.merge(order('created_at ASC')) }

  scope :all_public, -> {
    where("commentable_type = 'Post' AND EXISTS(
      SELECT 1 FROM posts WHERE posts.id = commentable_id AND posts.public = true
    )")
  }

  before_save do
    self.text.strip! unless self.text.nil?
  end

  after_commit on: :create do
    parent.update_comments_counter
    parent.touch(:interacted_at) if parent.respond_to?(:interacted_at)
  end

  after_destroy do
    self.parent.update_comments_counter
    participation = author.participations.find_by(target_id: post.id)
    participation.unparticipate! if participation.present?
  end

  def text= text
     self[:text] = text.to_s.strip #to_s if for nil, for whatever reason
  end

  def add_mention_subscribers?
    super && parent.author.local?
  end

  class Generator < Diaspora::Federated::Generator
    def self.federated_class
      Comment
    end

    def initialize(person, target, text)
      @text = text
      super(person, target)
    end

    def relayable_options
      {post: @target, text: @text}
    end
  end
end
