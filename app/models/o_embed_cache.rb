class OEmbedCache < ActiveRecord::Base
  serialize :data
  attr_accessible :url

  has_many :posts

  def self.find_or_create_by_url(url)
   cache = OEmbedCache.find_or_build_by_url(url)
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
      cache.save
    end
  end
end
