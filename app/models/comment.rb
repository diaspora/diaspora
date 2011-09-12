#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Comment < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  require File.join(Rails.root, 'lib/youtube_titles')
  include YoutubeTitles
  include ROXML

  include Diaspora::Webhooks
  include Diaspora::Guid
  include Diaspora::Relayable

  include Diaspora::Socketable
  include Diaspora::Taggable
  include Diaspora::Likeable

  acts_as_taggable_on :tags
  extract_tags_from :text
  before_create :build_tags

  xml_attr :text
  xml_attr :diaspora_handle

  belongs_to :post
  belongs_to :author, :class_name => 'Person'
  
  validates :text, :presence => true, :length => { :maximum => 2500 }
  validates :post, :presence => true

  serialize :youtube_titles, Hash

  before_save do
    self.text.strip! unless self.text.nil?
  end

  after_save do
    self.post.touch
  end

  after_create do
    self.parent.update_comments_counter
  end

  after_destroy do
    self.parent.update_comments_counter
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def notification_type(user, person)
    if user.owns?(self.post)
      return Notifications::CommentOnPost
    elsif user_has_commented_on_others_post?(person, self.post, user)
      return Notifications::AlsoCommented
    else
      return false
    end
  end

  def user_has_commented_on_others_post?(author, post, user)
    Comment.comments_by_author_on_post_exist?(author, post.id) && self.author_id != user.person.id
  end

  def self.comments_by_author_on_post_exist?(author, post_id)
    Comment.exists?(:author_id => author.id, :post_id => post_id)
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
end
