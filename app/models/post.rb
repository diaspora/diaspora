class Post 
  require 'lib/common'
  include ApplicationHelper 
  
  # XML accessors must always preceed mongo field tags

  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks


  key :person_id, ObjectId
  
  belongs_to :person, :class_name => 'Person'

  timestamps!

  after_save :send_to_view
  after_save :print
  
  def self.stream
    Post.sort(:created_at.desc).all
  end

  def each
    yield self 
  end

 def self.newest(person = nil)
    return self.last if person.nil?
    self.where(:person_id => person.id).sort(:created_at.desc)
  end

 def self.my_newest
   self.newest(User.first)
 end
  def self.newest_by_email(email)
    self.where(:person_id => Person.where(:email => email).first.id).last
  end


  protected

  def send_to_view
    self.reload
    WebSocket.update_clients(self)
  end
  

end

