class Blog < Post
  
  xml_accessor :title
  xml_accessor :body

  
  field :title
  field :body
  
  validates_presence_of :title, :body
  
end
