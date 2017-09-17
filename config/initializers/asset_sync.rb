# frozen_string_literal: true

if defined? AssetSync
  AssetSync.configure do |config|
    config.enabled = true
    
    config.fog_provider = 'AWS'
    config.aws_access_key_id = AppConfig.environment.s3.key.get
    config.aws_secret_access_key = AppConfig.environment.s3.secret.get
    config.fog_directory = AppConfig.environment.s3.bucket.get
  
    # Increase upload performance by configuring your region
    config.fog_region = AppConfig.environment.s3.region.get
    #
    # Don't delete files from the store
    # config.existing_remote_files = "keep"
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
