class Comment
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :text
  xml_reader :person,  :to_xml => proc {|person| person.email}
  
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

