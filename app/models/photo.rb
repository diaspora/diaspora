class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document

  mount_uploader :image, ImageUploader
end
