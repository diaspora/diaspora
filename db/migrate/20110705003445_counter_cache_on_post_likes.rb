class CounterCacheOnPostLikes < ActiveRecord::Migration
  def self.up
    add_column :posts, :likes_count, :integer, :default => 0
  end

  def self.down
    remove_column :posts, :likes_count
  end
end
