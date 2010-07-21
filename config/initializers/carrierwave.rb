CarrierWave.configure do |config|
  #config.grid_fs_database = "#diaspora-#{Rails.env}"
  #config.grid_fs_host = 'localhost'
  #config.grid_fs_access_url = "/images"
  #config.storage = :grid_fs
  config.storage = :file
end
