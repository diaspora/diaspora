class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :email
  xml_accessor :url
 
  key :email, String
  key :url, String
  
  one :profile, :class_name => 'Profile', :foreign_key => :person_id
  many :posts, :class_name => 'Post', :foreign_key => :person_id

  timestamps!

  validates_presence_of :url
  validates_format_of :url, :with =>
     /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix
  
     
  validates_true_for :url, :logic => lambda { self.url_unique?}


  validates_presence_of :email
  
  before_validation :clean_url
 
  def real_name
    self.profile.first_name + " " + self.profile.last_name
  end

  
  protected
  
  def url_unique?
    same_url = Person.first(:url => self.url)
    return same_url.nil? || same_url.id == self.id
  end

  def clean_url
    self.url ||= "http://localhost:3000/" if self.class == User
    if self.url
      self.url = 'http://' + self.url unless self.url.match('http://' || 'https://')
      self.url = self.url + '/' if self.url[-1,1] != '/'
    end
  end
 end
