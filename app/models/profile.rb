#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Profile
  include MongoMapper::EmbeddedDocument
  require File.join(Rails.root, 'lib/diaspora/webhooks')
  include Diaspora::Webhooks
  include ROXML

  xml_reader :diaspora_handle
  xml_reader :first_name
  xml_reader :last_name
  xml_reader :image_url
  xml_reader :birthday
  xml_reader :gender
  xml_reader :bio
  xml_reader :searchable

  key :diaspora_handle, String
  key :first_name, String
  key :last_name,  String
  key :image_url,  String
  key :birthday,   Date
  key :gender,     String
  key :bio,        String
  key :searchable, Boolean, :default => true

  after_validation :strip_names
  validates_length_of :first_name, :maximum => 32
  validates_length_of :last_name,  :maximum => 32

  before_save :strip_names

  attr_accessible :first_name, :last_name, :image_url, :birthday, :gender, :bio, :searchable


  def person
    self._parent_document
  end

  def diaspora_handle
    #get the parent diaspora handle, unless we want to access a profile without a person
    (self._parent_document) ? self.person.diaspora_handle : self[:diaspora_handle]
  end

  def image_url= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
      super(absolutify_local_url(url))
    end
  end

  protected

  def strip_names
    self.first_name.strip! if self.first_name
    self.last_name.strip! if self.last_name
  end

  private
  def absolutify_local_url url
    pod_url = APP_CONFIG[:pod_url].dup
    pod_url.chop! if APP_CONFIG[:pod_url][-1,1] == '/'
    "#{pod_url}#{url}"
  end
end
