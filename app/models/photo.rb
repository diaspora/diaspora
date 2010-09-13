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


class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader
  
  xml_accessor :remote_photo
  xml_accessor :caption
  xml_reader :album_id 

  key :album_id, ObjectId
  key :caption,  String
  key :remote_photo_path
  key :remote_photo_name

  belongs_to :album, :class_name => 'Album'

  timestamps!

  validates_presence_of :album
  validates_true_for :album_id, :logic => lambda {self.validate_album_person}

  before_destroy :ensure_user_picture

  def self.instantiate(params = {})
    image_file = params[:user_file]
    params.delete :user_file
    
    photo = Photo.new(params)
    photo.image.store! image_file
    photo.save
    photo
  end

  def validate_album_person
    album.person_id == person_id
  end
  
  def remote_photo
    image.url.nil? ? (remote_photo_path + '/' + remote_photo_name) : image.url
  end

  def remote_photo= remote_path
    name_start = remote_path.rindex '/'
    self.remote_photo_path = remote_path.slice(0, name_start )
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def url(name = nil)
    if remote_photo_path
      name = name.to_s + "_" if name
      person.url.chop + remote_photo_path + "/" + name.to_s + remote_photo_name
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
    {:thumb_url => url(:thumb_medium), :id => id, :album_id => album_id}
  end
end
