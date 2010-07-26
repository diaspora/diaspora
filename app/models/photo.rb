class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader
  
  xml_accessor :remote_photo
  xml_reader :album_id 

  key :album_id, ObjectId

   
  belongs_to :album, :class_name => 'Album'
  timestamps!

  validates_presence_of :album

  def self.instantiate params = {}
    image_file = params[:user_file][0]
    params.delete :user_file
    photo = Photo.new(params)
    photo.image.store! image_file
    photo
  end
  
  after_save :log_save_inspection 
  validates_true_for :album_id, :logic => lambda {self.validate_album_person}

  def validate_album_person
    album.person_id == person_id
  end
  def remote_photo
    @remote_photo ||= User.owner.url.chop + image.url
  end

  def remote_photo= remote_path
    Rails.logger.info("Setting remote photo with id #{id}")
    @remote_photo = remote_path
    image.download! remote_path
    image.store!
    Rails.logger.info("Setting remote photo with id #{id}")
  end
end
