class StatusMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :message
  
  
  validates_presence_of :message
end
