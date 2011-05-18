class AddColumnForBookmark < ActiveRecord::Migration
  def self.up
    add_column(:posts, :target_url, :string)
    add_column(:posts, :image_url, :string)
    add_column(:posts, :image_height, :integer)
    add_column(:posts, :image_width, :integer)
  end

  def self.down
    remove_column(:posts, :image_width)
    remove_column(:posts, :image_height)
    remove_column(:posts, :image_url)
    remove_column(:posts, :target_url)
  end
end
