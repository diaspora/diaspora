class Blog < Post
  
  xml_accessor :title
  xml_accessor :body

  
  field :title
  field :body
  
  validates_presence_of :title, :body
  
  def self.newest(owner_email)
    Blog.last(:conditions => {:owner => owner_email})
  end
  
  def self.my_newest
    Blog.newest(User.first.email)
  end
end
