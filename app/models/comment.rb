class Comment
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks
  include Encryptable
  
  xml_accessor :text
  xml_accessor :person, :as => Person
  xml_accessor :post_id
  
  
  key :text, String
  timestamps!
  
  key :post_id, ObjectId
  belongs_to :post, :class_name => "Post"
  
  key :person_id, ObjectId
  belongs_to :person, :class_name => "Person"
  
  after_save :send_to_view
  

  def ==(other)
    (self.message == other.message) && (self.person.email == other.person.email)
  end
  
  def push_upstream
    push_to([post.person])
  end

  def push_downstream
    push_to(post.people_with_permissions)
  end

  #ENCRYPTION
  
  before_validation :sign_if_mine, :sign_if_my_post
  #validates_true_for :creator_signature, :logic => lambda {self.verify_creator_signature}
  validates_true_for :post_creator_signature, :logic => lambda {self.verify_post_creator_signature}
  
  xml_accessor :creator_signature
  xml_accessor :post_creator_signature
  
  key :creator_signature, String
  key :post_creator_signature, String

  def signable_accessors
    accessors = self.class.roxml_attrs.collect{|definition| 
      definition.accessor}
    accessors.delete 'person'
    accessors.delete 'creator_signature'
    accessors.delete 'post_creator_signature'
    accessors
  end

  def signable_string
    signable_accessors.collect{|accessor| 
      (self.send accessor.to_sym).to_s}.join ';'
  end

  def verify_post_creator_signature
    unless person == User.owner
      verify_signature(post_creator_signature, post.person)
    else
      true
    end
  end
  
  
  protected
   def sign_if_my_post
    if self.post.person == User.owner
      self.post_creator_signature = sign
    end
  end 
 
  def send_to_view
    SocketsController.new.outgoing(self)
  end
end
