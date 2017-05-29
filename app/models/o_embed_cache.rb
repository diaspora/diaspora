class OEmbedCache < ActiveRecord::Base
  serialize :data
  validates :data, :presence => true

  has_many :posts

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :data
  end

  def self.find_or_create_by(opts)
   cache = OEmbedCache.find_or_initialize_by(opts)
   return cache if cache.persisted?
   cache.fetch_and_save_oembed_data! # make after create callback and drop this method ?
   cache
  end

  def fetch_and_save_oembed_data!
    begin
      response = OEmbed::Providers.get(self.url, {:maxwidth => 420, :maxheight => 420, :frame => 1, :iframe => 1})
    rescue => e
      # noop
    else
      self.data = response.fields
      self.data['trusted_endpoint_url'] = response.provider.endpoint
      self.fix_embed_code
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

  def fix_embed_code
    if ['video', 'rich'].include? self.data['type'] and self.is_trusted_and_has_html?
      subs = [
        # youtube
        { :from => /("http:\/\/www\.youtube\.com\/embed\/.{11}\?)/,
          :to   => '\1wmode=transparent&' },
        # soundcloud
        { :from => /(<object height=".+" width=".+">\s*)(<param name="movie" value="http:\/\/player\.soundcloud\.com\/player\.swf)/,
          :to   => '\1<param name="wmode" value="transparent"></param>\2' },
      ]

      subs.each {|s| self.data['html'].gsub!(s[:from], s[:to])}
    end
  end
end
