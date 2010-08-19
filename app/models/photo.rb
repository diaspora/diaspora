class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader
  
  xml_accessor :remote_photo
  xml_accessor :caption
  xml_reader :album_id 

  key :album_id, ObjectId
  key :caption, String

   
  belongs_to :album, :class_name => 'Album'
  timestamps!

  validates_presence_of :album

  def self.instantiate(params = {})
    image_file = params[:user_file].first
    params.delete :user_file
    
    photo = Photo.new(params)
    photo.image.store! image_file
    photo.save
    photo
  end
  
  after_save :log_save_inspection 
  validates_true_for :album_id, :logic => lambda {self.validate_album_person}

  before_destroy :ensure_user_picture


  def validate_album_person
    album.person_id == person_id
  end
  
  def remote_photo
    url
  end

  def remote_photo= remote_path
    name_start = remote_path.rindex '/'
    @remote_photo_path = remote_path.slice(0, name_start )
    @remote_photo_name = remote_path.slice(name_start, remote_path.length)
    save
    raise "Failed to set path for : #{self.inspect}" if Photo.first(:id => self.id).url.nil?
  end

  def url name = nil
    if @remote_photo_path
      @remote_photo_path + name.to_s + @remote_photo_name
    else
      image.url name
    end
  end

  def ensure_user_picture
    users = Person.all('profile.image_url' => image.url(:thumb_medium) )
    users.each{ |user|
      user.profile.update_attributes!(:image_url => nil)
    } 
  end

  def thumb_hash
    {:thumb_url => image.url(:thumb_medium), :id => id, :album_id => album_id}
  end
end
