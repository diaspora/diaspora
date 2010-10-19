#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Profile
  include MongoMapper::EmbeddedDocument
  require File.join(Rails.root, 'lib/diaspora/webhooks')
  include Diaspora::Webhooks
  include ROXML

  xml_reader :person_id
  xml_accessor :first_name
  xml_accessor :last_name
  xml_accessor :image_url

  key :first_name, String
  key :last_name,  String
  key :image_url,  String

  validates_presence_of :first_name, :last_name

  before_save :strip_names

  def person_id
    self._parent_document.id
  end

  def person
    self._parent_document
  end

  private
  def strip_names
    first_name.strip!
    last_name.strip!
  end
end
