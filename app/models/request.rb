#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Request  
  require File.join(Rails.root, 'lib/diaspora/webhooks')
  
  include MongoMapper::Document
  include Magent::Async
  include Diaspora::Webhooks
  include ROXML

  xml_reader :diaspora_handle
  xml_reader :destination_url
  xml_reader :callback_url

  key :aspect_id,       ObjectId
  key :destination_url, String
  key :callback_url,    String
  key :exported_key,    String

  key :diaspora_handle, String

  belongs_to :person

  validates_presence_of :destination_url, :callback_url
  before_validation :clean_link

  def self.instantiate(options = {})
    person = options[:from]
    self.new(:person_id       => person.id,
             :destination_url => options[:to],
             :callback_url    => person.receive_url,
             :diaspora_handle => person.diaspora_handle,
             :aspect_id       => options[:into])
  end

  def reverse_for accepting_user
    Request.new(
      :diaspora_handle => accepting_user.diaspora_handle,
      :destination_url => self.callback_url,
      :callback_url    => self.destination_url,
      :person_id => accepting_user.person.id
    )
  end

  
  def self.send_request_accepted(user, person, aspect)
    self.async.send_request_accepted!(user.id, person.id, aspect.id).commit!
  end

  def self.send_request_accepted!(user_id, person_id, aspect_id)
    Notifier.request_accepted(user_id, person_id, aspect_id).deliver
  end

  def self.send_new_request(user, person)
    self.async.send_new_request!(user.id, person.id).commit!
  end

  def self.send_new_request!(user_id, person_id)
    Notifier.new_request(user_id, person_id).deliver
  end


protected
  def clean_link
    if self.destination_url
      self.destination_url = self.destination_url.strip
      self.destination_url = 'http://' + self.destination_url unless self.destination_url.match('https?://')
      self.destination_url = self.destination_url + '/' if self.destination_url[-1,1] != '/'
    end
  end
end
