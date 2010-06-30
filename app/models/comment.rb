class Comment
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  
  xml_accessor :text
  xml_accessor :person, :as => Person
  xml_accessor :post_id
  
  key :text, String
  key :target, String
  timestamps!
  
  key :post_id, ObjectId
  belongs_to :post, :class_name => "Post"
  
  key :person_id, ObjectId
  belongs_to :person, :class_name => "Person"
  
  after_save :send_friends_comments_on_my_posts

  def ==(other)
    (self.message == other.message) && (self.person.email == other.person.email)
  end
  
  
  protected
  
  def send_friends_comments_on_my_posts
    if (User.first.mine?(self.post) && self.person.is_a?(Friend))
      self.push_to(self.post.friends_with_permissions)
    end
  end
end