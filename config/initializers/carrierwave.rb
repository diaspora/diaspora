CarrierWave.configure do |config|
  config.grid_fs_database = "#diaspora-#{Rails.env}"
  config.grid_fs_host = 'localhost'
  config.grid_fs_access_url = "/GridFS"
  config.storage = :grid_fs
end
