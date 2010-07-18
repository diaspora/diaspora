class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  before_validation {puts "I'M GONNA VALIDATE"} 
  before_save {puts "I'M GONNA SAVE"} 
  before_create {puts "I'M GONNA CREATE"} 
  mount_uploader :image, ImageUploader
end
