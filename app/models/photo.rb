#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader

  xml_accessor :remote_photo
  xml_accessor :caption

  key :caption,  String
  key :remote_photo_path
  key :remote_photo_name

  timestamps!

  attr_accessible :caption

  before_destroy :ensure_user_picture

  def self.instantiate(params = {})
    photo = super(params)
    image_file = params.delete(:user_file)

    photo.image.store! image_file
    photo
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
    {:thumb_url => url(:thumb_medium), :id => id, :album_id => nil}
  end

  def mutable?
    true
  end
end

