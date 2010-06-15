class StatusMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  
  xml_accessor :message
  xml_accessor :owner

  
  field :message
  field :owner
  
  validates_presence_of :message
  
  before_create :add_owner
  
  protected
  
  def add_owner
    self.owner ||= User.first.email    
  end

end
