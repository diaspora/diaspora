class Request
  require 'lib/diaspora/webhooks'
  include MongoMapper::Document
  include Diaspora::Webhooks
  include ROXML
  include Encryptable

  xml_accessor :_id
  xml_accessor :person, :as => Person
  xml_accessor :destination_url
  xml_accessor :callback_url
  xml_accessor :exported_key, :cdata => true

  key :destination_url, String
  key :callback_url, String
  key :person_id, ObjectId
  key :exported_key, String

  belongs_to :person
  
  validates_presence_of :destination_url, :callback_url

  #validates_format_of :destination_url, :with =>
    #/^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

  before_validation :clean_link

  scope :for_user, lambda{ |user| where(:destination_url => user.url) }
  scope :from_user, lambda{ |user| where(:destination_url.ne => user.url) }

  def self.instantiate(options = {})
    person = options[:from]
    self.new(:destination_url => options[:to], :callback_url => person.receive_url, :person => person, :exported_key => person.export_key)
  end
  


  
  def set_pending_friend
    p = Person.first(:id => self.person.id)
    
    self.person.save  #save pending friend
    
  end
 
#ENCRYPTION
    #before_validation :sign_if_mine
    #validates_true_for :creator_signature, :logic => lambda {self.verify_creator_signature}
    
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

  def clean_link
    if self.destination_url
      self.destination_url = 'http://' + self.destination_url unless self.destination_url.match('https?://')
      self.destination_url = self.destination_url + '/' if self.destination_url[-1,1] != '/'
    end
  end
end
