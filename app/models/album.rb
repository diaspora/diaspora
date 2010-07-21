class Album 
  include MongoMapper::Document

  key :name, String

  belongs_to :person, :class_name => 'Person'
  many :photos, :class_name => 'Photo', :foreign_key => :album_id

  timestamps!

  validates_presence_of :name

  def prev_photo(photo)
    n_photo = self.photos.where(:created_at.lt => photo.created_at).sort(:created_at.desc).first
    n_photo ? n_photo : self.photos.sort(:created_at.desc).first
  end

  def next_photo(photo)
    p_photo = self.photos.where(:created_at.gt => photo.created_at).sort(:created_at.asc).first
    p_photo ? p_photo : self.photos.sort(:created_at.desc).last
  end

end
