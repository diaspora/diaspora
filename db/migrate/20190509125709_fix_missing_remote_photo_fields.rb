# frozen_string_literal: true

class FixMissingRemotePhotoFields < ActiveRecord::Migration[5.1]
  def up
    Photo.where(remote_photo_path: nil).each do |photo|
      photo.write_attribute(:unprocessed_image, photo.read_attribute(:processed_image))
      photo.update_remote_path
      photo.save!
    end
  end
end
