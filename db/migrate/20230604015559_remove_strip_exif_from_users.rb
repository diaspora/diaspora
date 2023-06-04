# frozen_string_literal: true

class RemoveStripExifFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :strip_exif, :boolean, default: true
  end
end
