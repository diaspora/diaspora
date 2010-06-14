class Friend
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :username
  field :url
  
  validates_presence_of :username, :url

end