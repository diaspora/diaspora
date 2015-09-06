#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ProcessedImage < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg png gif tiff)
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

  def resize_and_crop(width, height)
    resize_to_limit(width, nil) do |img|
      _cols, rows = img[:dimensions]
      if rows > height
        img.gravity "Center"
        img.crop "#{width}x#{height}>+0+#{(height / 2)}"
      end
      img
    end
  end

  version :thumb_small do
    process resize_to_fill: [50, 50]
  end
  version :thumb_medium do
    process resize_to_limit: [100, 100]
  end
  version :thumb_large do
    process resize_and_crop: [300, 500]
  end
  version :scaled_full do
    process resize_to_limit: [700, nil]
  end
end
