class Blog < Post
  
  xml_accessor :title
  xml_accessor :body

  
  key :title, String
  key :body, String
  
  validates_presence_of :title, :body
  
end
