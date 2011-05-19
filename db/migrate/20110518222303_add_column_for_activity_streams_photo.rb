class AddColumnForActivityStreamsPhoto < ActiveRecord::Migration
  def self.up
    add_column(:posts, :object_url, :string)
    add_column(:posts, :image_url, :string)
    add_column(:posts, :image_height, :integer)
    add_column(:posts, :image_width, :integer)

    add_column(:posts, :provider_display_name, :string)
    add_column(:posts, :actor_url, :string)
  end

  def self.down
    remove_column(:posts, :actor_url)
    remove_column(:posts, :provider_display_name)

    remove_column(:posts, :image_width)
    remove_column(:posts, :image_height)
    remove_column(:posts, :image_url)
    remove_column(:posts, :object_url)
  end
end
