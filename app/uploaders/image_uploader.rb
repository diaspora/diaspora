#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def cache_dir
    if ENV['HEROKU'] 
      "#{RAILS_ROOT}/tmp/uploads" 
    else
      super
    end
  end

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    model.id.to_s + File.extname(@filename) if @filename
  end

  version :thumb_small do
    process :resize_to_fill => [50,50]
  end

  version :thumb_medium do
    process :resize_to_fill => [100,100]
  end

  version :thumb_large do
    process :resize_to_fill => [200,200]
  end

  version :scaled_full do
    process :resize_to_limit => [700,700]
  end
end
