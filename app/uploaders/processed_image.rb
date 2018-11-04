# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ProcessedImage < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
  end

  def extension_whitelist
    %w[jpg jpeg png gif]
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

  version :thumb_small do
    process resize_to_fill: [50, 50, combine_options: {unsharp: "1.5x1+0.7+0.02"}]
  end
  version :thumb_medium do
    process resize_to_limit: [100, 100, combine_options: {unsharp: "1.5x1+0.7+0.02"}]
  end
  version :thumb_large do
    process resize_to_limit: [300, 1500]
  end
  version :scaled_full do
    process resize_to_limit: [700, nil]
  end
end
