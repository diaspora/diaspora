class Group 
  include MongoMapper::Document
  
  key :name, String

  many :people, :class_name => 'Person'
  belongs_to :user, :class_name => 'User'

  timestamps!

end

