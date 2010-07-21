class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader

  key :album_id, ObjectId
  one :album, :class_name => 'Album'
end
