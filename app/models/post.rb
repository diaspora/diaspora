class Post 
  require 'lib/encryptable'
  include MongoMapper::Document
  include ApplicationHelper 
  include ROXML
  include Diaspora::Webhooks
  include Encryptable
  include Diaspora::Socketable

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :person_id, ObjectId
  key :user_refs, Integer, :default => 0 

  many :comments, :class_name => 'Comment', :foreign_key => :post_id
  belongs_to :person, :class_name => 'Person'
  
  timestamps!
  
  cattr_reader :per_page
  @@per_page = 10
    
  before_destroy :propogate_retraction
  after_destroy :destroy_comments

  def self.instantiate params
    self.create params
  end

  #ENCRYPTION
  xml_accessor :creator_signature
  key :creator_signature, String
  
  def signable_accessors
    accessors = self.class.roxml_attrs.collect{|definition| 
      definition.accessor}
    accessors.delete 'person'
    accessors.delete 'creator_signature'
    accessors
  end

  def signable_string
    signable_accessors.collect{|accessor| 
      (self.send accessor.to_sym).to_s}.join ';'
  end
  
  protected
  def destroy_comments
    comments.each{|c| c.destroy}
  end
  
  def propogate_retraction
    self.person.owner.retract(self)
  end
end

