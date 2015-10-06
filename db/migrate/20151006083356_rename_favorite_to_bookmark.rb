class RenameFavoriteToBookmark < ActiveRecord::Migration
  def change
    rename_table :favorites, :bookmarks
  end
end
