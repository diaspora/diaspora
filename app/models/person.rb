class Person
  include Mongoid::Document
  include ROXML

  xml_accessor :email
  xml_accessor :real_name

  field :email
  field :real_name

  has_many_related :posts

  validates_presence_of :email, :real_name

end
