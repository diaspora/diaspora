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


class Post 
  require 'lib/encryptable'
  include MongoMapper::Document
  include ApplicationHelper 
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Socketable

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :person_id, ObjectId
  key :user_refs, Integer, :default => 0 

  many :comments, :class_name => 'Comment', :foreign_key => :post_id
  belongs_to :person, :class_name => 'Person'
  
  timestamps!
  
  cattr_reader :per_page
  @@per_page = 10
    
  before_destroy :propogate_retraction
  after_destroy :destroy_comments

  def self.instantiate params
    self.create params.to_hash
  end


  def as_json(opts={})
    {
      :post => {
        :id     => self.id,
        :person => self.person.as_json,
      }
    }
  end
  
  protected
  def destroy_comments
    comments.each{|c| c.destroy}
  end
  
  def propogate_retraction
    self.person.owner.retract(self)
  end
end

