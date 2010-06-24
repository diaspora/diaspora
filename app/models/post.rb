class Post 
  require 'lib/common'
  include ApplicationHelper 
  
  # XML accessors must always preceed mongo field tags

  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  include Diaspora::Webhooks


  belongs_to_related :person
  

  before_create :set_defaults

  after_save :send_to_view

  @@models = ["StatusMessage", "Bookmark", "Blog"]

  def self.stream
    # Need to explicitly name each inherited model for dev environment
    query = if Rails.env == "development"
        Post.criteria.all(:_type => @@models)
      else
        Post.criteria.all
      end
    query.order_by( [:created_at, :desc] )
  end

  def each
    yield self 
  end

 def self.newest(person = nil)
    return self.last if person.nil?
    self.where(:person_id => person.id).last
  end

  def self.newest_by_email(email)
    self.where(:person_id => Person.where(:email => email).first.id).last
  end


  protected

  def send_to_view
    self.reload
    WebSocket.update_clients(self)
  end

  def set_defaults
    self.person ||= User.first
  end
end

