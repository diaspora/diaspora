class Post 
  require 'lib/common'
  include ApplicationHelper 
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :_id
  xml_accessor :owner_signature
  xml_accessor :person, :as => Person

  key :person_id, ObjectId

  many :comments, :class_name => 'Comment', :foreign_key => :post_id
  belongs_to :person, :class_name => 'Person'
  
  
  cattr_reader :per_page
  @@per_page = 10
    
  timestamps!

  after_save :send_to_view
  after_save :notify_people
 
  before_destroy :propagate_retraction
  after_destroy :destroy_comments, :remove_from_view

  def self.stream
    Post.sort(:created_at.desc).all
  end

 def self.newest(person = nil)
    return self.last if person.nil?

    self.first(:person_id => person.id, :order => '_id desc')
  end

 def self.my_newest
   self.newest(User.owner)
 end
  def self.newest_by_email(email)
    self.newest(Person.first(:email => email))
  end

#ENCRYPTION
  
  before_validation :sign_if_mine
  #validates_true_for :owner_signature, :logic => lambda {self.verify_signature}
  
  key :owner_signature, String
  
  def signable_accessors
    accessors = self.class.roxml_attrs.collect{|definition| 
      definition.accessor}
    accessors.delete 'person'
    accessors.delete 'owner_signature'
    accessors
  end

  def signable_string
    signable_accessors.collect{|accessor| 
      (self.send accessor.to_sym).to_s}.join ';'
  end

  def verify_signature
    return false unless owner_signature && person.key_fingerprint
    validity = nil
    GPGME::verify(owner_signature, signable_string, 
      {:armor => true, :always_trust => true}){ |signature|
        validity =  signature.status == GPGME::GPG_ERR_NO_ERROR &&
          signature.fpr == person.key_fingerprint
    }
    return validity
  end
  
  protected
  def sign_if_mine
    if self.person == User.owner
      self.owner_signature = GPGME::sign(signable_string,nil,
        {:armor=> true, :mode => GPGME::SIG_MODE_DETACH})
    end
  end

  def destroy_comments
    comments.each{|c| c.destroy}
  end
  
  def propagate_retraction
    Retraction.for(self).notify_people
  end

  def send_to_view
    SocketsController.new.outgoing(self)
  end
  
  def remove_from_view
    SocketsController.new.outgoing(Retraction.for(self))
  end

end

