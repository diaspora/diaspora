class Album 
  require 'lib/diaspora/webhooks'
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks
  include Encryptable

  xml_reader :name
  xml_reader :person, :as => Person
  xml_reader :_id
  key :name, String

  belongs_to :person, :class_name => 'Person'
  many :photos, :class_name => 'Photo', :foreign_key => :album_id

  timestamps!

  validates_presence_of :name, :person

  before_destroy :destroy_photos
  after_save :notify_people
  before_destroy :propagate_retraction
  
  def self.instantiate params
    self.create params
  end

  def self.mine_or_friends(friend_param, current_user)
    if friend_param
      Album.where(:person_id => current_user.friend_ids)
    else
      current_user.person.albums
    end
  end
  
  def prev_photo(photo)
    n_photo = self.photos.where(:created_at.lt => photo.created_at).sort(:created_at.desc).first
    n_photo ? n_photo : self.photos.sort(:created_at.desc).first
  end

  def next_photo(photo)
    p_photo = self.photos.where(:created_at.gt => photo.created_at).sort(:created_at.asc).first
    p_photo ? p_photo : self.photos.sort(:created_at.desc).last
  end

  #ENCRYPTION
  xml_accessor :creator_signature
  key :creator_signature, String
  
  def signable_accessors
    accessors = self.class.roxml_attrs.collect{|definition| 
      definition.accessor}
    accessors.delete 'person'
    accessors.delete 'creator_signature'
    accessors
  end

  def signable_string
    signable_accessors.collect{|accessor| 
      (self.send accessor.to_sym).to_s}.join ';'
  end


  protected
  def destroy_photos
    photos.each{|p| p.destroy}
  end

  def propagate_retraction
    Retraction.for(self).notify_people
  end
end
