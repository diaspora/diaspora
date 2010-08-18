class Group 
  include MongoMapper::Document
  
  key :name, String
  validates_presence_of :name

  key :person_ids, Array
  key :request_ids, Array

  many :people, :in => :person_ids, :class_name => 'Person'
  many :requests, :in => :request_ids, :class_name => 'Request'

  belongs_to :user, :class_name => 'User'

  timestamps!

end

