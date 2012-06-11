#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#Excon needs to see the CA Cert Bundle file
ENV["SSL_CERT_FILE"] = AppConfig[:ca_file]
CarrierWave.configure do |config|
  if !Rails.env.test? && AppConfig[:s3_key] && AppConfig[:s3_secret] && AppConfig[:s3_bucket] && AppConfig[:s3_region]
    config.storage = :fog
    config.cache_dir = Rails.root.join('tmp', 'uploads').to_s
    config.fog_credentials = {
        :provider               => 'AWS',       
        :aws_access_key_id      => AppConfig[:s3_key],       
        :aws_secret_access_key  => AppConfig[:s3_secret],
        :region                 => AppConfig[:s3_region]
    }
    config.fog_directory = AppConfig[:s3_bucket]
  else
    config.storage = :file
  end
end
