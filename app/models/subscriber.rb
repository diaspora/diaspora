class Subscriber
  include MongoMapper::Document

  key :url
  key :topic

  validates_presence_of :url, :topic

end
