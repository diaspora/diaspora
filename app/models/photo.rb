#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Photo < Post
  require 'carrierwave/orm/mongomapper'
  include MongoMapper::Document
  mount_uploader :image, ImageUploader

  xml_accessor :remote_photo
  xml_accessor :caption
  xml_reader :status_message_id

  key :caption,  String
  key :remote_photo_path
  key :remote_photo_name
  key :random_string

  key :status_message_id, ObjectId
  
  timestamps!

  belongs_to :status_message

  attr_accessible :caption
  validate :ownership_of_status_message

  before_destroy :ensure_user_picture

  def ownership_of_status_message
    message = StatusMessage.find_by_id(self.status_message_id)
    if status_message_id && message 
      self.diaspora_handle == message.diaspora_handle 
    else
      true
    end
  end

  def self.instantiate(params = {})
    photo = super(params)
    image_file = params.delete(:user_file)
    photo.random_string = gen_random_string(10)

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
    people = Person.all('profile.image_url' => absolute_url(:thumb_medium) )
    people.each{ |person|
      person.profile.update_attributes(:image_url => nil)
    }
  end

  def thumb_hash
    {:thumb_url => url(:thumb_medium), :id => id, :album_id => nil}
  end

  def mutable?
    true
  end

  def absolute_url *args
    pod_url = APP_CONFIG[:pod_url].dup
    pod_url.chop! if APP_CONFIG[:pod_url][-1,1] == '/'
    "#{pod_url}#{url(*args)}"
  end
  
  def self.gen_random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    string = ""
    1.upto(len) { |i| string << chars[rand(chars.size-1)] }
    return string
  end
  
  def as_json(opts={})
    {
      :photo => {
        :id     => self.id,
        :url    => self.url(:thumb_medium)
      }
    }
  end
  
end

