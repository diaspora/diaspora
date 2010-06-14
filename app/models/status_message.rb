class StatusMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  
  xml_accessor :message

  
  field :message
  
  validates_presence_of :message

end
