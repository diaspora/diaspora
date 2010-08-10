class Group 
  include MongoMapper::Document
  
  key :name, String

  key :person_ids, Array

  many :people, :in => :person_ids, :class_name => 'Person'
  belongs_to :user, :class_name => 'User'

  timestamps!

end

