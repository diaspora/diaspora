class Subscriber
  include MongoMapper::Document

  key :url

  validates_presence_of :url

end
