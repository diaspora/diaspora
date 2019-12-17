# frozen_string_literal: true

class FixPendingProfilePhotos < ActiveRecord::Migration[5.1]
  def up
    Photo.where(pending: true).each do |photo|
      photo.update(pending: false) if Profile.where(image_url: photo.url(:thumb_large)).exists?
    end
  end
end
