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

  belongs_to :post
  belongs_to :person

  validates_presence_of :text, :post

  serialize :youtube_titles, Hash
  before_save do
    get_youtube_title text
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
    else
      return false
    end
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

  def self.hash_from_post_ids post_ids
    hash = {}
    comments = where(:post_id => post_ids)
    post_ids.each do |id|
      hash[id] = []
    end
    comments.each do |comment|
      hash[comment.post_id] << comment
    end
    hash.each_value {|comments| comments.sort!{|c1, c2| c1.created_at <=> c2.created_at }}
    hash
  end
end
