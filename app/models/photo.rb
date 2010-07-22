class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader
  
  xml_reader :remote_photo
  xml_reader :album_id 

  key :album_id, ObjectId

   
  belongs_to :album, :class_name => 'Album'
  timestamps!

  validates_presence_of :album

  def self.instantiate params = {}
    image_file = params[:image]
    params.delete :image
    photo = Photo.new(params)
    photo.image.store! image_file
    photo
  end

  def remote_photo
    User.owner.url.chop + image.url
  end

  def remote_photo= remote_path
    image.download! remote_path
    image.store!
  end
end
