class Person
  include MongoMapper::Document
  include ROXML

  xml_accessor :_id
  xml_accessor :email
  xml_accessor :url
  xml_accessor :serialized_key
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

  validates_presence_of :email, :url, :serialized_key, :profile
  validates_format_of :url, :with =>
     /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix
  

  after_destroy :remove_all_traces
 
  def real_name
    "#{profile.first_name.to_s} #{profile.last_name.to_s}"
  end

  def key
    OpenSSL::PKey::RSA.new( serialized_key )
  end

  def key= new_key
    raise TypeError unless new_key.class == OpenSSL::PKey::RSA
    serialized_key = new_key.export
  end
  def export_key
    key.public_key.export
  end


  ######## Posting ########
  def post(class_name, options = {})
    options[:person] = self
    model_class = class_name.to_s.camelize.constantize
    post = model_class.instantiate(options)
  end

  ######## Commenting  ########
  def comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    c = Comment.new(:person_id => self.id, :text => text, :post => options[:on])
    if c.save
      if mine?(c.post)
        c.push_to(c.post.people_with_permissions)  # should return plucky query
      else
        c.push_to([c.post.person])
      end
      true
    end
    false
  end
  
  ##profile
  def update_profile(params)
    if self.update_attributes(params)
      puts self.profile.class
      self.profile.notify_people!
      true
    else
      false
    end
  end

  def mine?(post)
    self.id == post.person.id
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
