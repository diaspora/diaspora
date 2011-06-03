class LockableUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :locked_at, :datetime
  end

  def self.down
    remove_column :users, :locked_at
  end
end
