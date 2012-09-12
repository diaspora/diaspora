class RemoveWallpaperFromProfile < ActiveRecord::Migration
  def up
    remove_column :profiles, :wallpaper
  end
  
  def down
    add_column :profiles, :wallpaper, :string
  end
end
