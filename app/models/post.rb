class Post 
  require 'lib/common'
  include ApplicationHelper 
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :person_id, ObjectId
  
  many :comments, :class_name => 'Comment', :foreign_key => :post_id
  belongs_to :person, :class_name => 'Person'
  
  
  cattr_reader :per_page
  @@per_page = 10
    
  timestamps!

  after_save :send_to_view
  after_save :notify_friends
  
  def self.stream
    Post.sort(:created_at.desc).all
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
      WebSocket.update_clients(self)
  end
  

end

