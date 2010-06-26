class Post 
  require 'lib/common'
  include ApplicationHelper 
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks


  key :person_id, ObjectId
  belongs_to :person, :class_name => 'Person'
  timestamps!



  after_save :send_to_view
  validates_presence_of :person
  
  
  
  def self.stream
    Post.sort(:created_at.desc).all
  end

  def each
    yield self 
  end

 def self.newest(person = nil)
    return self.last if person.nil?

    self.first(:person_id => person.id, :order => '_id desc')
  end

 def self.my_newest
   self.newest(User.first)
 end
  def self.newest_by_email(email)
    self.newest(Person.first(:email => email))
  end


  protected

  def send_to_view
    self.reload
    WebSocket.update_clients(self)
  end
  

end

