if defined?(AssetSync)
  require File.join(File.dirname(__FILE__), '..', '..', 'app', 'models', 'app_config')
  AssetSync.configure do |config|
    config.fog_provider = 'AWS'
    config.fog_directory = AppConfig[:s3_bucket]
    config.aws_access_key_id =  AppConfig[:s3_key]
    config.aws_secret_access_key = AppConfig[:s3_secret]

    # Don't delete files from the store
    # config.existing_remote_files = "keep"
    #
    # Increase upload performance by configuring your region
    # config.fog_region = 'eu-west-1'
    #
    # Automatically replace files with their equivalent gzip compressed version
    # config.gzip_compression = true
    #
    # Use the Rails generated 'manifest.yml' file to produce the list of files to 
    # upload instead of searching the assets directory.
    # config.manifest = true
    #
    # Fail silently.  Useful for environments such as Heroku
    # config.fail_silently = true
  end
end