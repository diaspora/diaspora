class AddUsernameToAdminUsers < ActiveRecord::Migration
  def self.up
    add_column :admin_users, :username, :string
  end
  
  AdminUser.find_by_email('admin@example.com').update_attribute(:username, 'admin@example.com')
  add_index :admin_users, :username, :unique => true

  def self.down
    remove_column :admin_users, :username
  end
end
