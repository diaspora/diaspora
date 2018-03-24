# frozen_string_literal: true

class OpenGraphCache < ApplicationRecord
  validates :title, :presence => true
  validates :ob_type, :presence => true
  validates :image, :presence => true
  validates :url, :presence => true

  has_many :posts

  acts_as_api
  api_accessible :backbone do |t|
    t.add :title
    t.add :ob_type
    t.add :image
    t.add :description
    t.add :url
    t.add :video_url
  end

  def image
    if AppConfig.privacy.camo.proxy_opengraph_thumbnails?
      Diaspora::Camo.image_url(self[:image])
    else
      self[:image]
    end
  end

  def self.find_or_create_by(opts)
    cache = OpenGraphCache.find_or_initialize_by(opts)
    cache.fetch_and_save_opengraph_data! unless cache.persisted?
    cache if cache.persisted? # Make this an after create callback and drop this method ?
  end

  def fetch_and_save_opengraph_data!
    object = OpenGraphReader.fetch!(self.url)

    return unless object

    self.title = object.og.title.truncate(255)
    self.ob_type = object.og.type
    self.image = object.og.image.url
    self.url = object.og.url
    self.description = object.og.description
    if object.og.video.try(:secure_url) && secure_video_url?(object.og.video.secure_url)
      self.video_url = object.og.video.secure_url
    end

    self.save
  rescue OpenGraphReader::NoOpenGraphDataError, OpenGraphReader::InvalidObjectError
  end

  def secure_video_url?(url)
    SECURE_OPENGRAPH_VIDEO_URLS.any? {|u| u =~ url }
  end
end
