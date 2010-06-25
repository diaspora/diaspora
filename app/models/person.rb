class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :email
  xml_accessor :real_name

  key :email, String
  key :real_name, String
  
  #key :post_ids, Array#, :typecast => ObjectId

  many :posts, :class_name => 'Post', :foreign_key => :person_id

  validates_presence_of :email, :real_name

end
