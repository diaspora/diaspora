class CounterCacheOnPostReshares < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end

  def self.up
    add_column :posts, :reshares_count, :integer, :default => 0

    if AppConfig.postgres?
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
    else # mysql
      execute "CREATE TEMPORARY TABLE posts_reshared SELECT * FROM posts WHERE type = 'Reshare'"
      execute %{
        UPDATE posts p1
        SET reshares_count = (
          SELECT COUNT(*)
          FROM posts_reshared p2
          WHERE p2.root_guid = p1.guid
        )
      }
    end

  end

  def self.down
    remove_column :posts, :reshares_count
  end
end
