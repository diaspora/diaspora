class AddObjectIdToPost < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  def self.up
    add_column(:posts, :objectId, :integer)
    execute("UPDATE posts SET objectId = object_url") if Post.count > 0
  end

  def self.down
    remove_column(:posts, :objectId, :integer)
  end
end
