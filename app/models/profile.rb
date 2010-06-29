class Profile
  include MongoMapper::Document
  
  key :first_name, String
  key :last_name, String

  key :person_id, ObjectId

  belongs_to :person

  validates_presence_of :first_name, :last_name, :person_id

end
