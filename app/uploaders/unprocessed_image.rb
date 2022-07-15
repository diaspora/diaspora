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

  def extension_allowlist
    %w[jpg jpeg png gif webp]
  end

  def filename
    model.random_string + extension if @filename
  end

  def extension
    needs_converting? ? ".webp" : File.extname(@filename)
  end

  def needs_converting?
    extname = File.extname(@filename)
    %w[.webp .gif].exclude?(extname) && !model.keep_original_format
  end

  process :basic_process

  def basic_process
    manipulate! do |img|
      img.combine_options do |i|
        i.auto_orient
        i.strip if strip_exif
      end

      img = yield(img) if block_given?

      img.format("webp") if needs_converting?
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
