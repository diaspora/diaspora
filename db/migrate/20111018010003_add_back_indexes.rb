class AddBackIndexes < ActiveRecord::Migration
  def self.up
    # reduce index size

    add_index :photos, :status_message_guid
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    remove_index :comments, :column => [:commentable_id, :commentable_type]
    remove_index :photos, :column => :status_message_guid

    # reduce index size
  end
end
