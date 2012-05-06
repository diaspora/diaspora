class WallpaperUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images/wallpaper"
  end

  def extension_white_list
    %w(jpg jpeg png tiff)
  end

  # Filename is associated with the user's diaspora handle, ensuring uniqueness
  # and that only one copy is kept in the filesystem.
  def filename
    Digest::MD5.hexdigest(model.diaspora_handle) + File.extname(@filename) if @filename
  end

  process :darken

  def darken
    manipulate! do |img|
      # img.brightness_contrast "-40x-50"
      # thanks, heroku.
      img.modulate "40,40"

      img = yield(img) if block_given?
      img
    end
  end
end