class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader

  key :album_id, ObjectId
  belongs_to :album, :class_name => 'Album'
  timestamps!

  validates_presence_of :album
end
