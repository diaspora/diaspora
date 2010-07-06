class FriendRequest
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  xml_name :friend_request
  xml_accessor :sender, :as => Person
  xml_accessor :recipient, :as => Person

  key :sender, Person
  key :recipient, Person

  validates_presence_of :sender, :recipient
  after_create :send_off

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

  def send_off
    push_to_recipient self.recipient
  end
  
end
