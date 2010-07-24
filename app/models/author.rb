class Author
  include MongoMapper::Document

  key :service, String
  key :feed_url, String
  key :avatar_thumbnail, String
  key :username, String
  key :profile_url, String
  key :hub, String

  many :ostatus_posts, :class_name => 'OstatusPost', :foreign_key => :author_id
  before_save :set_defaults 
  before_destroy :delete_posts

  def self.instantiate(opts)
    author = Author.first(:feed_url => opts[:feed_url])
    author ||= Author.create(opts)
  end

  private

  def set_defaults
    self.avatar_thumbnail = nil if self.avatar_thumbnail == 0
    self.service = self.url if self.service == 0
  end

  def delete_posts
    self.ostatus_posts.delete_all
  end
 end
