#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HandleValidator < ActiveModel::Validator
  def validate(document)
    unless document.diaspora_handle == document.person.diaspora_handle
      document.errors[:base] << "Diaspora handle and person handle must match"
    end
  end
end

class Comment
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  require File.join(Rails.root, 'lib/youtube_titles')
  include YoutubeTitles
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks
  include Encryptable
  include Diaspora::Socketable

  xml_reader :text
  xml_reader :diaspora_handle
  xml_reader :post_id
  xml_reader :_id

  key :text,      String
  key :post_id,   ObjectId
  key :person_id, ObjectId
  key :diaspora_handle, String

  belongs_to :post,   :class_name => "Post"
  belongs_to :person, :class_name => "Person"

  validates_presence_of :text, :diaspora_handle, :post
  validates_with HandleValidator

  before_save do
    get_youtube_title text
  end

  timestamps!

  def notification_type(user, person)
    if self.post.diaspora_handle == user.diaspora_handle
      return "comment_on_post"
    elsif self.post.comments.all(:diaspora_handle => user.diaspora_handle) != [] && self.diaspora_handle != user.diaspora_handle
      return "also_commented"
    else
      return false
    end
  end

  def subscribers(user)
    if user.owns?(self.post)
      p = self.post.subscribers(user)
    elsif user.owns?(self)
      p = [self.post.person]
    end
    p
  end

  def receive(user, person)
    commenter = self.person
    unless self.post.person == user.person || self.verify_post_creator_signature
      Rails.logger.info("event=receive status=abort reason='comment signature not valid' recipient=#{user.diaspora_handle} sender=#{self.post.person.diaspora_handle} payload_type=#{self.class} post_id=#{self.post_id}")
      return
    end

    user.visible_people = user.visible_people | [commenter]
    user.save

    commenter.save

    #sign comment as the post creator if you've been hit UPSTREAM
    if user.owns? self.post
      self.post_creator_signature = self.sign_with_key(user.encryption_key)
      self.save
    end

    #dispatch comment DOWNSTREAM, received it via UPSTREAM
    unless user.owns?(self)
      self.save
      user.dispatch_comment(self) 
    end

    self.socket_to_uid(user, :aspect_ids => self.post.aspect_ids)
    self
  end

  #ENCRYPTION

  xml_reader :creator_signature
  xml_reader :post_creator_signature

  key :creator_signature, String
  key :post_creator_signature, String

  def signable_accessors
    accessors = self.class.roxml_attrs.collect{|definition|
      definition.accessor}
    accessors.delete 'person'
    accessors.delete 'creator_signature'
    accessors.delete 'post_creator_signature'
    accessors
  end

  def signable_string
    signable_accessors.collect{|accessor|
      (self.send accessor.to_sym).to_s}.join ';'
  end

  def verify_post_creator_signature
    verify_signature(post_creator_signature, post.person)
  end

  def signature_valid?
    verify_signature(creator_signature, person)
  end

  def self.hash_from_post_ids post_ids
    hash = {}
    comments = self.on_posts(post_ids)
    post_ids.each do |id|
      hash[id] = []
    end
    comments.each do |comment|
      hash[comment.post_id] << comment
    end
    hash.each_value {|comments| comments.sort!{|c1, c2| c1.created_at <=> c2.created_at }}
    hash
  end


  scope :on_posts, lambda { |post_ids| 
    where(:post_id.in => post_ids)
  }
end
