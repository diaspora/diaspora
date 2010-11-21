#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Aspect
  include MongoMapper::Document

  key :name,        String
  key :request_ids, Array
  key :post_ids,    Array

  many :contacts, :foreign_key => 'aspect_ids', :class_name => 'Contact'
  many :requests, :in => :request_ids, :class_name => 'Request'
  many :posts,    :in => :post_ids,    :class_name => 'Post'

  belongs_to :user, :class_name => 'User'

  validates_presence_of :name
  validates_length_of :name, :maximum => 20
  validates_uniqueness_of :name, :scope => :user_id
  attr_accessible :name
  
  before_validation do
    name.strip!
  end
  
  timestamps!

  def to_s
    name
  end
  
  def person_objects
    person_ids = people.map{|x| x.person_id}
    Person.all(:id.in => person_ids)
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

