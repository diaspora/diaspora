class AddPhotosExportToUser < ActiveRecord::Migration
  def up
    add_column :users, :exported_photos_file, :string
    add_column :users, :exported_photos_at, :datetime
    add_column :users, :exporting_photos, :boolean, default: false
  end

  def down
    remove_column :users, :exported_photos_file
    remove_column :users, :exported_photos_at
    remove_column :users, :exporting_photos
  end
end
