class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :email

  key :email, String
  
  one :profile, :class_name => 'Profile', :foreign_key => :person_id
  many :posts, :class_name => 'Post', :foreign_key => :person_id

  validates_presence_of :email
  
  def real_name
    self.profile.first_name + " " + self.profile.last_name
  end
end
