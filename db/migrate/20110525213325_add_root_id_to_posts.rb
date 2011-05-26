class AddRootIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :root_id, :integer
  end

  def self.down
    remove_column :posts, :root_id
  end
end
