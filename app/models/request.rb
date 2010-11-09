#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Request  
  require File.join(Rails.root, 'lib/diaspora/webhooks')
  
  include MongoMapper::Document
  include Magent::Async
  include Diaspora::Webhooks
  include ROXML

  xml_reader :sender_handle
  xml_reader :recipient_handle

  belongs_to :into, :class => Aspect
  belongs_to :from, :class => Person
  belongs_to :to,   :class => Person

  validates_presence_of :from, :to
  #before_validation :clean_link

  def self.instantiate(opts = {})
    self.new(:from => opts[:from],
             :to   => opts[:to],
             :into => opts[:into])
  end

  def reverse_for accepting_user
    Request.new(
      :from => accepting_user.person,
      :to => self.from
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

  def sender_handle
    from.diaspora_handle
  end
  def sender_handle= sender_handle
    self.from = Person.first(:diaspora_handle => sender_handle)
  end

  def recipient_handle
    to.diaspora_handle
  end
  def recipient_handle= recipient_handle
    self.to = Person.first(:diaspora_handle => recipient_handle)
  end

  def diaspora_handle
    self.from.diaspora_handle
  end

end
