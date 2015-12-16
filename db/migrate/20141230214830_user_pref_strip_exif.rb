class UserPrefStripExif < ActiveRecord::Migration
  def up
    add_column :users, :strip_exif, :boolean, default: true
  end
  
  def down
    remove_column :users, :strip_exif
  end
end
