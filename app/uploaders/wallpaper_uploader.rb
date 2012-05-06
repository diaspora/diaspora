class WallpaperUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  process :darken

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg png tiff)
  end

  #def filename
  #  SecureRandom.hex(10) + File.extname(@filename) if @filename
  #end

  def darken
    manipulate! do |img|
      img.brightness_contrast "-40x-50"
      img = yield(img) if block_given?
      img
    end
  end
end