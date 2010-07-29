class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :_id
  xml_accessor :email
  xml_accessor :url
  xml_accessor :key_fingerprint
  xml_accessor :profile, :as => Profile
  
  
  key :email, String
  key :url, String
  key :active, Boolean, :default => false
  key :key_fingerprint, String

  one :profile, :class_name => 'Profile'
  many :posts, :class_name => 'Post', :foreign_key => :person_id
  many :albums, :class_name => 'Album', :foreign_key => :person_id

  timestamps!

  before_validation :clean_url
  validates_presence_of :email, :url, :key_fingerprint
  validates_format_of :url, :with =>
     /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix
  
  validates_true_for :url, :logic => lambda { self.url_unique?}

  after_destroy :remove_all_traces, :remove_key

  scope :friends,  where(:_type => "Person", :active => true)


 
  def real_name
    "#{profile.first_name.to_s} #{profile.last_name.to_s}"
  end

  def key
    GPGME::Ctx.new.get_key key_fingerprint
  end
  
  def export_key
    GPGME::export(key_fingerprint, :armor => true)
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

  private

  def remove_all_traces
    self.posts.delete_all
  end

  def remove_key
    puts 'Removing key from keyring in test environment' if Rails.env == 'test'
    ctx = GPGME::Ctx.new
    ctx.delete_key(key)
  end

 end
