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

  protected

  def send_to_view
    self.reload
    WebSocket.update_clients(self)
  end
  

end

