#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

  def filename
    model.random_string + model.id.to_s + File.extname(@filename) if @filename
  end

  def post_process
    self.send(:remove_versions!)
    unless self.path.include?('.gif')
      ImageUploader.instance_eval do
        version :thumb_small do
          process :resize_to_fill => [50,50]
        end

        version :thumb_medium do
          process :resize_to_fill => [100,100]
        end

        version :thumb_large do
          process :resize_to_fill => [300,300]
        end

        version :scaled_full do
          process :resize_to_limit => [700,700]
        end
      end

      self.recreate_versions!
      self.model.update_photo_remote_path
      self.model.save
    else
      false
    end
  end

  version :scaled_full
  version :thumb_large
  version :thumb_medium
  version :thumb_small
end
