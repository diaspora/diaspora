class OEmbedCache < ActiveRecord::Base
  serialize :data
  attr_accessible :url

  has_many :posts

  def self.find_or_create_by_url(url)
   cache = OEmbedCache.find_or_initialize_by_url(url)
   return cache if cache.persisted?
   cache.fetch_and_save_oembed_data!
   cache
  end

  def fetch_and_save_oembed_data!
    begin
      response = OEmbed::Providers.get(self.url, {:maxwidth => 420, :maxheight => 420, :frame => 1, :iframe => 1})
    rescue Exception => e
      # noop
    else
      self.data = response.fields
      self.data['trusted_endpoint_url'] = response.provider.endpoint
      self.save
    end
  end

  def is_trusted_and_has_html?
    self.from_trusted? and self.data.has_key?('html')
  end

  def from_trusted?
    SECURE_ENDPOINTS.include?(self.data['trusted_endpoint_url'])
  end

  def options_hash(prefix = 'thumbnail_')
    return nil unless self.data.has_key?(prefix + 'url')
    {
      :height => self.data.fetch(prefix + 'height', ''),
      :width => self.data.fetch(prefix + 'width', ''),
      :alt => self.data.fetch('title', ''),
    }
  end
end
