#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

CarrierWave.configure do |config|
  if APP_CONFIG[:s3_key] && APP_CONFIG[:s3_secret] && APP_CONFIG[:s3_bucket]
    config.storage = :s3
    config.s3_access_key_id = APP_CONFIG[:s3_key]
    config.s3_secret_access_key = APP_CONFIG[:s3_secret]
    config.s3_bucket = APP_CONFIG[:s3_bucket]
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
  end
end
