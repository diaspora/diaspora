class Comment
  include MongoMapper::Document
  include ROXML
  xml_accessor :text
  xml_accessor :person, :as => Person
  
  key :text, String
  key :target, String
  timestamps!
  
  key :post_id, ObjectId
  belongs_to :post, :class_name => "Post"
  
  key :person_id, ObjectId
  belongs_to :person, :class_name => "Person"
  


  def ==(other)
    (self.message == other.message) && (self.person.email == other.person.email)
  end

end

