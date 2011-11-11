class CounterCacheOnPostReshares < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end

  def self.up
    add_column :posts, :reshares_count, :integer, :default => 0

    execute %{
      UPDATE posts
      SET reshares_count = (
        SELECT COUNT(*)
        FROM posts p2
        WHERE
          p2.type = 'Reshare'
          AND p2.root_guid = posts.guid
      )
    }
  end

  def self.down
    remove_column :posts, :reshares_count
  end
end
