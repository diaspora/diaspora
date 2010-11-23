#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Contact
  include MongoMapper::Document

  belongs_to :user
  validates_presence_of :user

  belongs_to :person
  validates_presence_of :person

  key :aspect_ids, Array, :typecast => 'ObjectId'  
  many :aspects, :in => :aspect_ids, :class_name => 'Aspect'
 
end
