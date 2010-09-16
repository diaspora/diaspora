#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


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

