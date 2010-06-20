class StatusMessage < Post
  #include StatusMessagesHelper
  
  xml_name :status_message
 
  xml_accessor :message
  field :message


  validates_presence_of :message
  
 
  def self.newest(owner_email)
    StatusMessage.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    StatusMessage.newest(User.first.email)
  end


  def ==(other)
    (self.message == other.message) && (self.owner == other.owner)
  end

end

