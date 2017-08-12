class UserPrefStripExif < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :strip_exif, :boolean, default: true
  end
  
  def down
    remove_column :users, :strip_exif
  end
end
