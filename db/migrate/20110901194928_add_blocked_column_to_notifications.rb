class AddBlockedColumnToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :blocker, :boolean, :default => false, :null => false
  end

  def self.down
    execute 'DELETE FROM notifications WHERE blocker = 1'
    remove_column :notifications, :blocker
  end
end
