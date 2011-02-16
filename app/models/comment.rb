#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Comment < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  require File.join(Rails.root, 'lib/youtube_titles')
  include YoutubeTitles
  include ROXML
  include Diaspora::Webhooks
  include Encryptable
  include Diaspora::Socketable
  include Diaspora::Guid

  xml_attr :text
  xml_attr :diaspora_handle
  xml_attr :post_guid
  xml_attr :creator_signature
  xml_attr :post_creator_signature

  belongs_to :post, :touch => true
  belongs_to :person

  validates_presence_of :text, :post
  validates_length_of :text, :maximum => 2500

  serialize :youtube_titles, Hash
  before_save do
    get_youtube_title text
    self.text.strip! unless self.text.nil?
  end
  def diaspora_handle
    person.diaspora_handle
  end
  def diaspora_handle= nh
    self.person = Webfinger.new(nh).fetch
  end
  def post_guid
    self.post.guid
  end
  def post_guid= new_post_guid
    self.post = Post.where(:guid => new_post_guid).first
  end

  def notification_type(user, person)
    if self.post.person == user.person
      return "comment_on_post"
    elsif self.post.comments.where(:person_id => user.person.id) != [] && self.person_id != user.person.id
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
    local_comment = Comment.where(:guid => self.guid).first
    comment = local_comment || self

    unless comment.post.person == user.person || comment.verify_post_creator_signature
      Rails.logger.info("event=receive status=abort reason='comment signature not valid' recipient=#{user.diaspora_handle} sender=#{self.post.person.diaspora_handle} payload_type=#{self.class} post_id=#{self.post_id}")
      return
    end

    #sign comment as the post creator if you've been hit UPSTREAM
    if user.owns? comment.post
      comment.post_creator_signature = comment.sign_with_key(user.encryption_key)
      comment.save
    end

    #dispatch comment DOWNSTREAM, received it via UPSTREAM
    unless user.owns?(comment)
      comment.save
      user.dispatch_comment(comment)
    end

    comment.socket_to_user(user, :aspect_ids => comment.post.aspect_ids)
    comment
  end

  #ENCRYPTION


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

end
