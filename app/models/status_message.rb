class StatusMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  include StatusMessagesHelper
  require 'lib/net/curl'

  xml_accessor :message
  xml_accessor :owner

   
  field :message
  field :owner
  
  validates_presence_of :message
  
  before_create :set_default_owner
  
  def self.newest(owner_email)
    StatusMessage.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    StatusMessage.newest(User.first.email)
  end

  def self.retrieve_from_friend(friend)
    StatusMessages.from_xml Curl.curl(friend.url+"status_messages.xml")
  end

  def ==(other)
    (self.message == other.message) && (self.owner == other.owner)
  end

  protected
  
  def set_default_owner
    self.owner ||= User.first.email 
  end

end

