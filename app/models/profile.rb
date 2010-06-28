class Profile
  include MongoMapper::Document
  
  key :first_name, String
  key :last_name, String

  belongs_to :person, :class_name => "Person"

  validates_presence_of :first_name, :last_name, :person

end
