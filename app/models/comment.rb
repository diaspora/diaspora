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

  xml_accessor :text
  xml_accessor :diaspora_handle
  xml_accessor :post_guid
  xml_accessor :guid

  belongs_to :post
  belongs_to :person

  validates_presence_of :text, :post

  before_save do
    get_youtube_title text
  end

  def notification_type(user, person)
    if self.post.diaspora_handle == user.diaspora_handle
      return "comment_on_post"
    else
      return false
    end
  end

  #ENCRYPTION

  xml_reader :creator_signature
  xml_reader :post_creator_signature

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
