#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

CarrierWave.configure do |config|
  if AppConfig[:s3_key] && AppConfig[:s3_secret] && AppConfig[:s3_bucket]
    config.storage = :s3
    config.s3_access_key_id = AppConfig[:s3_key]
    config.s3_secret_access_key = AppConfig[:s3_secret]
    config.s3_bucket = AppConfig[:s3_bucket]
    config.s3_use_ssl = true
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
  end
end
