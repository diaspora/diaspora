class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps
  
  
  field :owner
  field :link
  field :title
  
  
  validates_presence_of :link  

  before_create :set_default_owner
  
  protected
  
  def set_default_owner
    self.owner ||= User.first.email   
  end
end