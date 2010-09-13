#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


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
