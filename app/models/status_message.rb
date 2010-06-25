class StatusMessage < Post
  #include StatusMessagesHelper
  
  xml_name :status_message
  xml_accessor :message
  
  key :message, String


  validates_presence_of :message
  
   def ==(other)
    (self.message == other.message) && (self.person.email == other.person.email)
  end

end

