class Blog
  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  
  xml_accessor :title
  xml_accessor :body
  xml_accessor :owner

  
  field :title
  field :body
  field :owner
  
  validates_presence_of :title, :body
  
  before_create :set_default_owner
  
  def self.newest(owner_email)
    Blog.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    Blog.newest(User.first.email)
  end
  
  protected
  
  def set_default_owner
    self.owner ||= User.first.email   
  end
end
