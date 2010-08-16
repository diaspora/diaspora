class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :_id
  xml_accessor :email
  xml_accessor :url
  xml_accessor :profile, :as => Profile
  
  
  key :email, String, :unique => true
  key :url, String

  key :serialized_key, String 


  key :owner_id, ObjectId
  key :user_refs, Integer, :default => 0 

  belongs_to :owner, :class_name => 'User'
  one :profile, :class_name => 'Profile'

  many :posts, :class_name => 'Post', :foreign_key => :person_id
  many :albums, :class_name => 'Album', :foreign_key => :person_id


  timestamps!

  before_validation :clean_url
  validates_presence_of :email, :url, :profile, :serialized_key 
  validates_format_of :url, :with =>
     /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix
  

  after_destroy :remove_all_traces
 
  def real_name
    "#{profile.first_name.to_s} #{profile.last_name.to_s}"
  end

  def encryption_key
    OpenSSL::PKey::RSA.new( serialized_key )
  end

  def encryption_key= new_key
    raise TypeError unless new_key.class == OpenSSL::PKey::RSA
    serialized_key = new_key.export
  end
  def export_key
    encryption_key.public_key.export
  end


  ######## Posting ########
  def post(class_name, options = {})
    options[:person] = self
    model_class = class_name.to_s.camelize.constantize
    post = model_class.instantiate(options)
    post.notify_people
    post.socket_to_uid owner.id if (owner_id && post.respond_to?( :socket_to_uid))
    post
  end

  ######## Commenting  ########
  def comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    c = Comment.new(:person_id => self.id, :text => text, :post => options[:on])
    if c.save
      dispatch_comment c
      c.socket_to_uid owner.id if owner_id
      true
    else
      Rails.logger.warn "this failed to save: #{c.inspect}"
    end
    false
  end
  
  def dispatch_comment( c )
    if owns? c.post
      push_downstream
    elsif owns? c
      c.push_upstream
    end
  end
  ##profile
  def update_profile(params)
    if self.update_attributes(params)
      self.profile.notify_people!
      true
    else
      false
    end
  end

  def owns?(post)
    self.id == post.person.id
  end

  def receive_url
    "#{self.url}receive/users/#{self.id}/"
  end

  def self.by_webfinger( identifier )
     Person.first(:email => identifier.gsub('acct:', ''))
  end
  
  def remote?
    owner.nil?
  end

  protected
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

 end
