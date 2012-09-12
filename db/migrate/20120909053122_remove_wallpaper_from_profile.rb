class RemoveWallpaperFromProfile < ActiveRecord::Migration
  def up
    add_column :profiles, :wallpaper, :string
  end
  def down
    remove_column: profiles, :wallpaper
end
