module FeatureFlags
  def self.new_publisher
    !(Rails.env.production? || Rails.env.staging?)
  end
end