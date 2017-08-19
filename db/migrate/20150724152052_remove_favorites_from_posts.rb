class RemoveFavoritesFromPosts < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :posts, :favorite
  end

  def self.down
    add_column :posts, :favorite, :boolean, default: false
  end
end
