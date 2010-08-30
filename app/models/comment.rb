class Comment
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks
  include Encryptable
  include Diaspora::Socketable
  
  xml_accessor :text
  xml_accessor :person, :as => Person
  xml_accessor :post_id
  xml_accessor :_id 
  
  key :text,      String
  key :post_id,   ObjectId
  key :person_id, ObjectId


  belongs_to :post,   :class_name => "Post"
  belongs_to :person, :class_name => "Person"

  validates_presence_of :text

  timestamps!
  
  def push_upstream
    Rails.logger.info("GOIN UPSTREAM")
    push_to([post.person])
  end

  def push_downstream
    Rails.logger.info("SWIMMIN DOWNSTREAM")
    push_to(post.people_with_permissions)
  end

  #ENCRYPTION
  
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
    verify_signature(post_creator_signature, post.person)
  end
  
  def signature_valid?
    verify_signature(creator_signature, person)
  end
  
end
