#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

CarrierWave.configure do |config|
  if ENV['S3_KEY'] && ENV['S3_SECRET'] && ENV['S3_BUCKET']
    config.storage = :s3
    config.s3_access_key_id = ENV['S3_KEY']
    config.s3_secret_access_key = ENV['S3_SECRET']
    config.s3_bucket = ENV['S3_BUCKET']
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  elsif ENV['CLOUDFILES_USERNAME'] && ENV['CLOUDFILES_KEY'] && ENV['CLOUDFILES_BUCKET']
    config.storage = :cloud_files
    config.cloud_files_username = ENV['CLOUDFILES_USERNAME']
    config.cloud_files_api_key = ENV['CLOUDFILES_KEY']
    config.cloud_files_container = ENV['CLOUDFILES_BUCKET']

    # providing the CDN url means carrierwave does not have to resolve it
    # on every upload request.
    if ENV['CLOUDFILES_CDN_URL']
      config.cloud_files_cdn_host = ENV['CLOUDFILES_CDN_URL']
    end

    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
  end
end
