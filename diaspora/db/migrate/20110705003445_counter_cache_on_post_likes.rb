class CounterCacheOnPostLikes < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  def self.up
    add_column :posts, :likes_count, :integer, :default => 0
    execute <<SQL if Post.count > 0
      UPDATE posts
      SET posts.likes_count = (SELECT COUNT(*) FROM likes WHERE likes.post_id = posts.id)
SQL
  end

  def self.down
    remove_column :posts, :likes_count
  end
end
