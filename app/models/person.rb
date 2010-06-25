class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :email
  xml_accessor :real_name

  key :type, String
  key :email, String
  key :real_name, String

  has_many :posts

  validates_presence_of :email, :real_name

end
