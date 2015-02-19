#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ExportedPhotos < CarrierWave::Uploader::Base

  def store_dir
    "uploads/users"
  end

  def filename
    "#{model.username}_photos_#{secure_token}.zip" if original_filename.present?
  end

  protected
  def secure_token(bytes = 16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.urlsafe_base64(bytes))
  end

end
