class AddOembedCacheToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :o_embed_cache_id, :integer
  end

  def self.down
    remove_column :posts, :o_embed_cache_id
  end
end
