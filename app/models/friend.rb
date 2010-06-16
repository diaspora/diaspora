class Friend
  include Mongoid::Document
  include ROXML

  xml_accessor :username
  xml_accessor :url

  field :username
  field :url

  validates_presence_of :username, :url
  
end
