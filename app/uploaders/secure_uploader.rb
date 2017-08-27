# frozen_string_literal: true

class SecureUploader < CarrierWave::Uploader::Base
  protected
  def secure_token(bytes = 16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.urlsafe_base64(bytes))
  end
end
