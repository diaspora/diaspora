class StatusMessage < Post
  #include StatusMessagesHelper
  
  xml_name :status_message
  xml_accessor :message
  
  key :message, String


  validates_presence_of :message
  
 

end

