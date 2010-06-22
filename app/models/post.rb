class Post 
  require 'lib/common'
  include ApplicationHelper 
  
  # XML accessors must always preceed mongo field tags

  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :owner
  xml_accessor :snippet
  xml_accessor :source

  field :owner
  field :source
  field :snippet

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


  protected

  def send_to_view
    self.reload
    WebSocket.update_clients(self)
  end

  def set_defaults
    user_email = User.first.email
    self.owner ||= user_email
    self.source ||= user_email
    self.snippet ||= user_email
  end
end

