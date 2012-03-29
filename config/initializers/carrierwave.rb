#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#Excon needs to see the CA Cert Bundle file
ENV["SSL_CERT_FILE"] = AppConfig[:ca_file]

CarrierWave.configure do |config|
  if !Rails.env.test? && AppConfig[:s3_key] && AppConfig[:s3_secret] && AppConfig[:s3_bucket] && AppConfig[:s3_region]
    config.storage = :s3
    config.s3_access_key_id = AppConfig[:s3_key]
    config.s3_secret_access_key = AppConfig[:s3_secret]
    config.s3_bucket = AppConfig[:s3_bucket]
    config.s3_region = AppConfig[:s3_region]
    config.s3_use_ssl = true
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
  end
end
