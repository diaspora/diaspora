class AddWallpaperToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :wallpaper, :string
  end
end
