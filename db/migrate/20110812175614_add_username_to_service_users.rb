class AddUsernameToServiceUsers < ActiveRecord::Migration
  def self.up
    add_column :service_users, :username, :string, :limit => 127
  end

  def self.down
    remove_column :service_users, :username
  end
end
