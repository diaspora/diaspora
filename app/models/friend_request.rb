class FriendRequest
  include MongoMapper::Document
  include Diaspora::Webhooks
  
  key :url, String

  attr_accessor :sender
  
  validates_presence_of :url

  before_save :shoot_off, :check_for_friend_requests

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

  def check_for_friend_requests
    f = Friend.where(:url => self.url).first
    if f
      f.active = true
      f.save
    end
  end

end
