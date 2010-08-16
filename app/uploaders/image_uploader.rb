class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :grid_fs

  def store_dir
    "files"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

#  def filename
#    model.id.to_s + File.extname(@filename)
#  end

  version :thumb_small do
    process :resize_to_fill => [30,30]
  end

  version :thumb_medium do
    process :resize_to_fill => [100,100]
  end

  version :thumb_large do
    process :resize_to_fill => [300,300]
  end

  version :scaled_full do
    process :resize_to_limit => [700,700]
  end
end
