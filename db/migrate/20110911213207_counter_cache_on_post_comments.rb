class CounterCacheOnPostComments < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end

  def self.up
    add_column :posts, :comments_count, :integer, :default => 0
    execute <<SQL if Post.count > 0
      UPDATE posts
      SET comments_count = (SELECT COUNT(*) FROM comments WHERE comments.post_id = posts.id)
SQL
  end

  def self.down
    remove_column :posts, :comments_count
  end
end
