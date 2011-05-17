#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

CarrierWave.configure do |config|
  if AppConfig[:s3_key] && AppConfig[:s3_secret] && AppConfig[:s3_bucket] && AppConfig[:s3_region]
    config.storage = :s3
    config.s3_access_key_id = AppConfig[:s3_key]
    config.s3_secret_access_key = AppConfig[:s3_secret]
    config.s3_bucket = AppConfig[:s3_bucket]
    config.s3_use_ssl = true
    config.cache_dir = "#{Rails.root}/tmp/uploads"
	case AppConfig[:s3_region]
	  when 'us' then nil 
	  when 'eu' then config.s3_region = 'eu-west-1'
	  when /eu.*/ then config.s3_region = AppConfig[:s3_region]
	  else nil # no need to change anything
	end
  else
    config.storage = :file
  end
end
