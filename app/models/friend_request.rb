class FriendRequest
  include MongoMapper::Document

  key :recipient_url
  
  attr_accessor :sender

  validates_presence_of :recipient_url

  after_create :send_off

  def send_off
    sender = Friend.from_xml( self.sender.to_xml )

    sender.push_to_url self.recipient_url
  end

end
