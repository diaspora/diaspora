class StatusMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  
  xml_accessor :message
  xml_accessor :owner

  
  field :message
  field :owner
  
  validates_presence_of :message
  
  before_create :set_default_owner
  
  def self.newest(owner_email)
    message = StatusMessage.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    StatusMessage.newest(User.first.email)
  end
  
  protected
  
  def set_default_owner
    self.owner ||= User.first.email   
  end
end
