class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader

  key :collection_id, ObjectId

  belongs_to :collection, :class_name => 'Collection'
end
