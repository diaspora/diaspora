class StatusMessage < Post
  #include StatusMessagesHelper
  
  xml_name :status_message
  xml_accessor :message
  
  key :message, String


  validates_presence_of :message
  
  def self.my_newest
    StatusMessage.where(:person_id => User.first.id).sort(:created_at.desc).first
  end

end

