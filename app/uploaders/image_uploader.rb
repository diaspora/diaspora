class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :grid_fs

  def store_dir
    "files/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  version :small_thumb do
    process :resize_to_fill => [100,100]
  end
end
