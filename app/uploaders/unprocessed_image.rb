#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UnprocessedImage < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

  process :orient_image

  def orient_image
    manipulate! do |img|
      img.auto_orient
      img
    end
  end

  version :thumb_small
  version :thumb_medium
  version :thumb_large
  version :scaled_full do
    process :get_version_dimensions 
  end

  def get_version_dimensions
    model.width, model.height = `identify -format "%wx%h " #{file.path}`.split(/x/)
  end
end
