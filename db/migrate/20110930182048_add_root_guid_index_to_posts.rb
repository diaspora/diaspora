class AddRootGuidIndexToPosts < ActiveRecord::Migration
  def self.up
    add_index :posts, :root_guid
  end

  def self.down
    remove_index :posts, :column => :root_guid
  end
end
