# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#Excon needs to see the CA Cert Bundle file
ENV['SSL_CERT_FILE'] = AppConfig.environment.certificate_authorities.get
CarrierWave.configure do |config|
  if !Rails.env.test? && AppConfig.environment.s3.enable?
    config.fog_provider = "fog/aws"
    require "carrierwave/storage/fog"
    config.storage = :fog
    config.cache_dir = Rails.root.join('tmp', 'uploads').to_s
    config.fog_credentials = {
        provider:              'AWS',
        aws_access_key_id:     AppConfig.environment.s3.key.get,
        aws_secret_access_key: AppConfig.environment.s3.secret.get,
        region:                AppConfig.environment.s3.region.get
    }
    if AppConfig.environment.s3.cache?
      config.fog_attributes['Cache-Control'] = 'max-age=31536000'
    end

    config.fog_directory = AppConfig.environment.s3.bucket.get
  else
    config.storage = :file
  end
end
