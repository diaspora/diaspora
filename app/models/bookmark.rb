class Bookmark < Post
  
  xml_accessor :link
  xml_accessor :title
  
  field :link
  field :title
  
  
  validates_presence_of :link  

end
