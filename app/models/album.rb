#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class Album < Post

  xml_reader :name

  key :name, String

  many :photos, :class_name => 'Photo', :foreign_key => :album_id

  timestamps!

  validates_presence_of :name, :person

  before_destroy :destroy_photos


  def self.mine_or_friends(friend_param, current_user)
    friend_param ? Album.find_all_by_person_id(current_user.friend_ids) : current_user.person.albums
  end

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
    self.photos.each{|p| p.destroy}
  end

end
