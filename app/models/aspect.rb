#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Aspect < ActiveRecord::Base
  belongs_to :user

  has_many :aspect_memberships
  has_many :contacts, :through => :aspect_memberships

  has_and_belongs_to_many :posts

  validates_presence_of :name
  validates_length_of :name, :maximum => 20
  validates_uniqueness_of :name, :scope => :user_id

  before_validation do
    name.strip!
  end

  def to_s
    name
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

