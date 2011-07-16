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

  acts_as_taggable_on :tags
  extract_tags_from :text
  before_create :build_tags

  xml_attr :text
  xml_attr :diaspora_handle

  belongs_to :post, :touch => true
  belongs_to :author, :class_name => 'Person'

  has_many :likes, :conditions => {:positive => true}, :dependent => :delete_all, :as => :target

  validates_presence_of :text, :post
  validates_length_of :text, :maximum => 2500

  serialize :youtube_titles, Hash
  before_save do
    self.text.strip! unless self.text.nil?
  end
  def diaspora_handle
    self.author.diaspora_handle
  end
  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def notification_type(user, person)
    if self.post.author == user.person
      return Notifications::CommentOnPost
    elsif self.post.comments.where(:author_id => user.person.id) != [] && self.author_id != user.person.id
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

  # @return [Integer]
  def update_likes_counter
    self.likes_count = self.likes.count
    self.save
  end
end
