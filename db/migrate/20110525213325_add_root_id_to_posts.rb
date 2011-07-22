class AddRootIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :root_guid, :string, :limit => 30
  end

  def self.down
    remove_column :posts, :root_guid
  end
end
