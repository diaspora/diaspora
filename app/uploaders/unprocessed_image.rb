#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UnprocessedImage < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/tmp_images"
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

  version :thumb_small do
    process :resize_to_limit => [100,100]
    process :strip
  end
  def strip
    manipulate! do |img|
      img.strip
      img = yield(img) if block_given?
      img
    end
  end

end
