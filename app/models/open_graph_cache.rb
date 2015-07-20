class OpenGraphCache < ActiveRecord::Base
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

    self.save
  rescue OpenGraphReader::NoOpenGraphDataError, OpenGraphReader::InvalidObjectError
  end
end
