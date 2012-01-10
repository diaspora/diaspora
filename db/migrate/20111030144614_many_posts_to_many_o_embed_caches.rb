class ManyPostsToManyOEmbedCaches < ActiveRecord::Migration
  def self.up
    create_table :embeddings do |t|
      t.integer :post_id
      t.integer :o_embed_cache_id
    end

    posts_with_embed = Post.where(Post.arel_table[:o_embed_cache_id].not_eq(nil))
    posts_with_embed.each do |p|
      p.o_embed_caches << p.o_embed_cache
      p.save
    end

    remove_column(:posts, :o_embed_cache_id)
  end

  def self.down
    add_column(:posts, :o_embed_cache_id, :integer)
    Post.reset_column_information

    OEmbedCache.all.each do |o|
      p = o.posts.first
      p.o_embed_cache_id = o.id
      p.save
    end

    drop_table :embeddings
  end
end
