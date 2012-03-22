class RemoveYoutubeTitles < ActiveRecord::Migration
  def self.up
    remove_column :comments, :youtube_titles
    remove_column :posts, :youtube_titles
  end

  def self.down
    add_column :comments, :youtube_titles, :text
    add_column :posts, :youtube_titles, :text
  end
end