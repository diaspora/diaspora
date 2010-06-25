class Post 
  require 'lib/common'
  include ApplicationHelper 
  
  # XML accessors must always preceed mongo field tags

  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks


  key :type, String
  key :person_id, ObjectId
  
  belongs_to :person


  #before_create :set_defaults

  after_save :send_to_view

  def each
    yield self 
  end

  protected

  def send_to_view
    self.reload
    WebSocket.update_clients(self)
  end

  def set_defaults
  end
end

