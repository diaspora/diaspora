class OpenGraphCache < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :ob_type
  attr_accessible :image
  attr_accessible :url
  attr_accessible :description

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

  def self.find_or_create_by_url(url)
   cache = OpenGraphCache.find_or_initialize_by_url(url)
   return cache if cache.persisted?
   cache.fetch_and_save_opengraph_data!
   return cache if cache.persisted?
   return nil
  end

  def fetch_and_save_opengraph_data!
    begin
      response = OpenGraph.new(self.url)
      if !response or response.type.nil?
        return
      end
    rescue => e
      # noop
    else
      self.title = response.title
      self.ob_type = response.type
      self.image = response.images[0]
      self.url = response.url
      self.description = response.description
      self.save
    end
  end
end
