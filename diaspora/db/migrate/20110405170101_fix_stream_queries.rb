class FixStreamQueries < ActiveRecord::Migration
  def self.up
    change_column :posts, :type, :string, :limit => 40
    remove_index :posts, :type
  end

  def self.down
    add_index :posts, :type
    change_column :posts, :type, :string, :limit => 127
  end
end
