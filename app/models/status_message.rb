class StatusMessage < Post
  include StatusMessagesHelper
  require 'lib/net/curl'
 
  xml_accessor :message
  field :message


  validates_presence_of :message
  
 
  def self.newest(owner_email)
    StatusMessage.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    StatusMessage.newest(User.first.email)
  end

  def self.retrieve_from_friend(friend)
    StatusMessages.from_xml Curl.get(friend.url+"status_messages.xml")
  end

  def ==(other)
    (self.message == other.message) && (self.owner == other.owner)
  end

end

