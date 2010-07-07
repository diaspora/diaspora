class FriendRequest
  include MongoMapper::Document
  include Diaspora::Webhooks
  
  key :url, String

  attr_accessor :sender
  
  validates_presence_of :url

  before_save :shoot_off

  def to_friend_xml
    friend = Friend.new
    friend.email = sender.email
    friend.url = sender.url
    friend.profile = sender.profile.clone

    friend.to_xml
  end

  def shoot_off
    push_friend_request_to_url(self.url)
  end

end
