class AddMissingTagFollowingsIndices < ActiveRecord::Migration
  def self.up
    add_index :tag_followings, :tag_id
    add_index :tag_followings, :user_id
    add_index :tag_followings, [:tag_id, :user_id], :unique => true
  end

  def self.down
    remove_index :tag_followings, :column => [:tag_id, :user_id]
    remove_index :tag_followings, :column => :user_id
    remove_index :tag_followings, :column => :tag_id
  end
end
