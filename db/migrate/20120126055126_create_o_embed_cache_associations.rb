class CreateOEmbedCacheAssociations < ActiveRecord::Migration
  class ::OEmbedCacheAssociation < ActiveRecord::Base
    belongs_to :post, :inverse_of => :o_embed_caches
    belongs_to :o_embed_cache, :inverse_of => :posts
  end
  
  class ::Post < ActiveRecord::Base
    belongs_to :o_embed_cache
    has_many :o_embed_cache_associations
    has_many :o_embed_caches, :through => :o_embed_cache_associations, :source => :o_embed_cache
  end
  
  class ::StatusMessage < Post
  end
  
  class ::OEmbedCache < ActiveRecord::Base
    has_many :direct_posts, :class_name => 'Post'
    has_many :o_embed_cache_associations
    has_many :posts, :through => :o_embed_cache_associations
  end
  
  def self.up
    create_table :o_embed_cache_associations do |t|
      t.integer :id
      t.integer :post_id
      t.integer :o_embed_cache_id
    end
    
    OEmbedCache.all.each do |cache|
      cache.posts << cache.direct_posts
    end
    
    remove_column :posts, :o_embed_cache_id
  end

  def self.down
    add_column :posts, :o_embed_cache_id, :integer
    
    Post.all.each do |post|
      post.o_embed_cache = post.o_embed_caches.first
      post.save
    end
    
    drop_table :o_embed_cache_associations
  end
end
