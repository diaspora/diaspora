class Post 
  require 'lib/message_handler' 
  
  
  # XML accessors must always preceed mongo field tags

  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML

  xml_accessor :owner
  xml_accessor :snippet
  xml_accessor :source

  field :owner
  field :source
  field :snippet

  before_create :set_defaults
  #after_update :notify_friends
  after_save :notify_friends
        
  @@queue = MessageHandler.new
  
  def notify_friends
    puts "hello"

    xml = prep_webhook
    #friends_with_permissions.each{ |friend| puts friend; Curl.post( "\"" + xml + "\" " + friend) }
    @@queue.add_post_request( friends_with_permissions, xml )
    @@queue.process
  end

  def prep_webhook  
    self.to_xml.to_s.chomp
  end

  def friends_with_permissions
    #friends = Friend.only(:url).map{|x| x = x.url + "/receive/"}
    #3.times {friends = friends + friends}
    #friends
    googles = []
    100.times{ googles <<"http://google.com/"} #"http://localhost:4567/receive/"} #"http://google.com/"}
    googles
  end

  @@models = ["StatusMessage", "Bookmark", "Blog"]

  def self.recent_ordered_posts
    # Need to explicitly name each inherited model for dev environment
    query = if Rails.env == "development"
        Post.criteria.all(:_type => @@models)
      else
        Post.criteria.all
      end
    query.order_by( [:created_at, :desc] )
  end


  protected

  def set_defaults
    user_email = User.first.email
    self.owner ||= user_email
    self.source ||= user_email
    self.snippet ||= user_email
  end


end

