#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class Request
  require 'lib/diaspora/webhooks'
  include MongoMapper::Document
  include Diaspora::Webhooks
  include ROXML

  xml_accessor :_id
  xml_accessor :person, :as => Person
  xml_accessor :destination_url
  xml_accessor :callback_url
  xml_accessor :exported_key, :cdata => true

  key :person_id,       ObjectId
  key :aspect_id,        ObjectId
  key :destination_url, String
  key :callback_url,    String
  key :exported_key,    String

  belongs_to :person

  validates_presence_of :destination_url, :callback_url
  before_validation :clean_link

  scope :for_user,  lambda{ |user| where(:destination_url    => user.receive_url) }
  scope :from_user, lambda{ |user| where(:destination_url.ne => user.receive_url) }

  def self.instantiate(options = {})
    person = options[:from]
    self.new(:destination_url => options[:to],
             :callback_url    => person.receive_url,
             :person          => person,
             :exported_key    => person.exported_key,
             :aspect_id        => options[:into])
  end

  def reverse_for accepting_user
    self.person          = accepting_user.person
    self.exported_key    = accepting_user.exported_key
    self.destination_url = self.callback_url
    self.save
  end

protected
  def clean_link
    if self.destination_url
      self.destination_url = 'http://' + self.destination_url unless self.destination_url.match('https?://')
      self.destination_url = self.destination_url + '/' if self.destination_url[-1,1] != '/'
    end
  end
end
