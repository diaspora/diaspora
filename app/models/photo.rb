#   Copyright (c) 2009, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Photo < Post
  require 'carrierwave/orm/activerecord'
  mount_uploader :image, ImageUploader

  xml_attr :remote_photo_path
  xml_attr :remote_photo_name

  xml_attr :text
  xml_attr :status_message_guid

  belongs_to :status_message

  attr_accessible :text, :pending
  validate :ownership_of_status_message

  before_destroy :ensure_user_picture
  after_create :queue_processing_job

  def ownership_of_status_message
    message = StatusMessage.find_by_id(self.status_message_id)
    if status_message_id && message
      self.diaspora_handle == message.diaspora_handle
    else
      true
    end
  end

  def self.diaspora_initialize(params = {})
    photo = super(params)
    image_file = params.delete(:user_file)
    photo.random_string = gen_random_string(10)
    photo.processed = false
    photo.image.store! image_file
    photo.update_photo_remote_path
    photo
  end

  def not_processed?
    !self.processed
  end

  def update_photo_remote_path
    unless self.image.url.match(/^https?:\/\//)
      pod_url = AppConfig[:pod_url].dup
      pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
      remote_path = "#{pod_url}#{self.image.url}"
    else
      remote_path = self.image.url
    end

    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def status_message_guid
    if self.status_message
      self.status_message.guid
    else
      nil
    end
  end

  def status_message_guid= new_sm_guid
    self.status_message= StatusMessage.where(:guid => new_sm_guid).first
  end

  def url(name = nil)
    if self.not_processed? || (!self.image.path.blank? && self.image.path.include?('.gif'))
      image.url
    elsif remote_photo_path
      name = name.to_s + '_' if name
      remote_photo_path + name.to_s + remote_photo_name
    else
      image.url(name)
    end
  end

  def ensure_user_picture
    profiles = Profile.where(:image_url => url(:thumb_large))
    profiles.each { |profile|
      profile.image_url = nil
      profile.save
    }
  end

  def thumb_hash
    {:thumb_url => url(:thumb_medium), :id => id, :album_id => nil}
  end

  def queue_processing_job
    Resque.enqueue(Job::ProcessPhoto, self.id)
  end

  def mutable?
    true
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
      :id => self.id,
        :url => self.url,
        :thumb_small => self.url(:thumb_small),
        :text => self.text
      }
    }
  end

  scope :on_statuses, lambda { |post_ids|
    where(:status_message_id => post_ids)
  }
end
