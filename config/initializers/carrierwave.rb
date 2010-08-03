CarrierWave.configure do |config|
  config.grid_fs_database = MongoMapper::database.name
  config.grid_fs_host = MongoMapper::connection.host
  config.grid_fs_access_url = "/images"
  config.storage = :grid_fs
  #config.storage = :file
end
