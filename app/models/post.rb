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

  many :comments, :class_name => 'Comment', :foreign_key => :post_id
  belongs_to :person, :class_name => 'Person'
  
  
  cattr_reader :per_page
  @@per_page = 10
    
  timestamps!

  after_save :send_to_view
 
  before_destroy :propagate_retraction
  after_destroy :destroy_comments, :remove_from_view

  def self.instantiate params
    self.create params
  end

#Querying
  def self.stream
    Post.sort(:created_at.desc).all
  end

  def self.newest_for(person)
    self.first(:person_id => person.id, :order => '_id desc')
  end

#ENCRYPTION
  before_validation :sign_if_mine
  validates_true_for :creator_signature, :logic => lambda {self.verify_creator_signature}
  
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
  
  def log_inspection
    Rails.logger.debug self.inspect
  end
  def log_save_inspection
    Rails.logger.debug "After saving, object is:"
    log_inspection
  end

protected
   def destroy_comments
    comments.each{|c| c.destroy}
  end
  
  def propagate_retraction
    Retraction.for(self).notify_people
  end



end

