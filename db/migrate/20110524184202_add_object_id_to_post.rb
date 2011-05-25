class AddObjectIdToPost < ActiveRecord::Migration
  def self.up
    add_column(:posts, :objectId, :integer)
    execute("UPDATE posts SET objectId = object_url")
  end

  def self.down
    add_column(:posts, :objectId, :integer)
  end
end
