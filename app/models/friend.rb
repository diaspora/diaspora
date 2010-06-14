class Friend
  include Mongoid::Document
  
  field :username
  field :url
  
  validates_presence_of :username, :url

end