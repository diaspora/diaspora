class AddPhotoCounterCacheToPost < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end

  def self.up
    add_column :posts, :photos_count, :integer, :default => 0
    execute <<SQL if Post.count > 0
      UPDATE posts
      SET photos_count = (SELECT COUNT(*) FROM photos WHERE photos.status_message_guid = posts.guid)
SQL
  end

  def self.down
    remove_column :posts, :photos_count
  end
end
