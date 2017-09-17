# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UnprocessedImage < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  attr_accessor :strip_exif

  def strip_exif
    @strip_exif || false
  end

  def store_dir
    "uploads/images"
  end

  def extension_whitelist
    %w[jpg jpeg png gif]
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

  process :basic_process

  def basic_process
    manipulate! do |img|
      img.auto_orient
      img.strip if strip_exif
      img = yield(img) if block_given?
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
