#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#Excon needs to see the CA Cert Bundle file
CarrierWave.configure do |config|
  if !Rails.env.test? && AppConfig.environment.s3.enable?
    config.storage = :fog
    config.cache_dir = Rails.root.join('tmp', 'uploads').to_s
    config.fog_credentials = {
        :provider               => 'AWS',
        :aws_access_key_id      => AppConfig.environment.s3.key,
        :aws_secret_access_key  => AppConfig.environment.s3.secret,
        :region                 => AppConfig.environment.s3.region
    }
    config.fog_directory = AppConfig.environment.s3.bucket
  else
    config.storage = :file
  end
end
