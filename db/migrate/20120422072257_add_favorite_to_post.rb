class AddFavoriteToPost < ActiveRecord::Migration
  def change
    add_column :posts, :favorite, :boolean, :default => 0
  end
end
