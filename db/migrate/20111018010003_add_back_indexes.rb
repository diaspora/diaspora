class AddBackIndexes < ActiveRecord::Migration
  def self.up
    # reduce index size
    change_column :comments, :commentable_type, :string, :default => "Post", :null => false, :length => 60
    change_column :share_visibilities, :shareable_type, :string, :default => "Post", :null => false, :length => 60

    add_index :photos, :status_message_guid
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    remove_index :comments, :column => [:commentable_id, :commentable_type]
    remove_index :photos, :column => :status_message_guid

    change_column :share_visibilities, :shareable_type
    change_column :comments, :commentable_type
  end
end
