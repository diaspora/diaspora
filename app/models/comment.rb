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
  require File.join(Rails.root, 'lib/diaspora/websocket')
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

  validates_presence_of :text, :diaspora_handle
  validates_with HandleValidator


  timestamps!

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

end
