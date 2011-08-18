#   Copyright (c) 2010, Diaspora Inc.  This file is
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
    fn = model.random_string
    fn += "-test" if Rails.env == 'test'
    fn += File.extname(@filename) if @filename
    fn
  end

  version :thumb_small
  version :thumb_medium
  version :thumb_large
  version :scaled_full
end
