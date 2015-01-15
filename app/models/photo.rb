#   Copyright (c) 2009, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Photo < ActiveRecord::Base
  include Diaspora::Federated::Shareable
  include Diaspora::Commentable
  include Diaspora::Shareable

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at
    t.add :author
    t.add lambda { |photo|
      { small: photo.url(:thumb_small),
        medium: photo.url(:thumb_medium),
        large: photo.url(:scaled_full) }
    }, as: :sizes
    t.add lambda { |photo|
      { height: photo.height,
        width: photo.width }
    }, as: :dimensions
  end

  mount_uploader :processed_image, ProcessedImage
  mount_uploader :unprocessed_image, UnprocessedImage

  xml_attr :remote_photo_path
  xml_attr :remote_photo_name

  xml_attr :text
  xml_attr :status_message_guid

  xml_attr :height
  xml_attr :width

  belongs_to :status_message, foreign_key: :status_message_guid, primary_key: :guid
  validates_associated :status_message
  delegate :author_name, to: :status_message, prefix: true

  validate :ownership_of_status_message

  before_destroy :ensure_user_picture
  after_destroy :clear_empty_status_message

  after_commit on: :create do
    queue_processing_job if author.local?
  end

  scope :on_statuses, ->(post_guids) {
    where(status_message_guid: post_guids)
  }

  def clear_empty_status_message
    if status_message && status_message.text_and_photos_blank?
      status_message.destroy
    else
      true
    end
  end

  def ownership_of_status_message
    message = StatusMessage.find_by_guid(status_message_guid)
    if status_message_guid && message
      diaspora_handle == message.diaspora_handle
    else
      true
    end
  end

  def self.diaspora_initialize(params = {})
    photo = new params.to_hash.slice(:text, :pending)
    photo.author = params[:author]
    photo.public = params[:public] if params[:public]
    photo.pending = params[:pending] if params[:pending]
    photo.diaspora_handle = photo.author.diaspora_handle

    photo.random_string = SecureRandom.hex(10)

    if params[:user_file]
      image_file = params.delete(:user_file)
      photo.unprocessed_image.store! image_file

    elsif params[:image_url]
      photo.remote_unprocessed_image_url = params[:image_url]
      photo.unprocessed_image.store!
    end

    photo.update_remote_path

    photo
  end

  def processed?
    processed_image.path.present?
  end

  def update_remote_path
    unless unprocessed_image.url.match(/^https?:\/\//)
      remote_path = "#{AppConfig.pod_uri.to_s.chomp('/')}#{unprocessed_image.url}"
    else
      remote_path = unprocessed_image.url
    end

    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def url(name = nil)
    if remote_photo_path
      name = name.to_s + '_' if name
      image_url = remote_photo_path + name.to_s + remote_photo_name
      if AppConfig.privacy.camo.proxy_remote_pod_images?
        Diaspora::Camo.image_url(image_url)
      else
        image_url
      end
    elsif processed?
      processed_image.url(name)
    else
      unprocessed_image.url(name)
    end
  end

  def ensure_user_picture
    profiles = Profile.where(image_url: url(:thumb_large))
    profiles.each do |profile|
      profile.image_url = nil
      profile.save
    end
  end

  def queue_processing_job
    Workers::ProcessPhoto.perform_async(id)
  end

  def mutable?
    true
  end
end
