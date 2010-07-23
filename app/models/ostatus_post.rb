class OstatusPost
  include MongoMapper::Document

  key :author_id, ObjectId
  key :message, String
  key :permalink, String
  key :published_at, DateTime

  belongs_to :author, :class_name => 'Author'

  cattr_reader :per_page
  @@per_page = 10

  timestamps!

end

