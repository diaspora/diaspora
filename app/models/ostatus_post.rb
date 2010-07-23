class OstatusPost
  include MongoMapper::Document

  key :author_id, ObjectId

  belongs_to :author, :class_name => 'Author'

end

