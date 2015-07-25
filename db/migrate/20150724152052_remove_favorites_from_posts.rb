class RemoveFavoritesFromPosts < ActiveRecord::Migration
  def self.up
    remove_column :posts, :favorite
  end

  def self.down
    add_column :posts, :favorite, :boolean, default: false
  end
end
