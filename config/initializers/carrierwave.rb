#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

CarrierWave.configure do |config|
  if ENV['S3_KEY'] && ENV['S3_SECRET'] && ENV['S3_BUCKET']
    config.storage = :s3
    config.s3_access_key_id = ENV['S3_KEY']
    config.s3_secret_access_key = ENV['S3_SECRET']
    config.s3_bucket = ENV['S3_BUCKET']
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
  end
end
