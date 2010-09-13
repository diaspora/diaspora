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


class Aspect
  include MongoMapper::Document
  
  key :name,        String
  key :person_ids,  Array
  key :request_ids, Array
  key :post_ids,    Array

  many :people,   :in => :person_ids,  :class_name => 'Person'
  many :requests, :in => :request_ids, :class_name => 'Request'
  many :posts,    :in => :post_ids,    :class_name => 'Post'

  belongs_to :user, :class_name => 'User'

  validates_presence_of :name

  timestamps!
  
  def to_s
    name
  end
  
  def posts_by_person_id( id )
    id = id.to_id
    posts.detect{|x| x.person.id == id }
  end

  def as_json(opts = {})
    {
      :aspect => {
        :name   => self.name,
        :people => self.people.each{|person| person.as_json},
        :posts  => self.posts.each {|post|   post.as_json  },
      }
    }
  end
end

