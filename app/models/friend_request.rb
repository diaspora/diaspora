class FriendRequest
  include MongoMapper::Document
  include ROXML

  xml_accessor :sender, :as => Person
  xml_accessor :recipient, :as => Person

  key :sender, Person
  key :recipient, Person

  validates_presence_of :sender, :recipient

  def accept
    f = Friend.new
    f.email = self.sender.email
    f.url = self.sender.url
    f.save
    self.destroy
  end

  def reject
    self.destroy
  end
  
end
