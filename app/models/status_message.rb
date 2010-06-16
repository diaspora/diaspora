class StatusMessage < Post
  
  xml_accessor :message
  field :message


  validates_presence_of :message
  
 
  def self.newest(owner_email)
    StatusMessage.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    StatusMessage.newest(User.first.email)
  end
  
end

