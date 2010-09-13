#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


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
