class Album 
  require 'lib/common'
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  xml_reader :name
  xml_reader :person, :as => Person
  xml_reader :_id
  key :name, String

  belongs_to :person, :class_name => 'Person'
  many :photos, :class_name => 'Photo', :foreign_key => :album_id

  timestamps!

  validates_presence_of :name

  before_destroy :destroy_photos
  after_save :notify_people

  def prev_photo(photo)
    n_photo = self.photos.where(:created_at.lt => photo.created_at).sort(:created_at.desc).first
    n_photo ? n_photo : self.photos.sort(:created_at.desc).first
  end

  def next_photo(photo)
    p_photo = self.photos.where(:created_at.gt => photo.created_at).sort(:created_at.asc).first
    p_photo ? p_photo : self.photos.sort(:created_at.desc).last
  end

  protected

  def destroy_photos
    photos.each{|p| p.destroy}
  end

end
