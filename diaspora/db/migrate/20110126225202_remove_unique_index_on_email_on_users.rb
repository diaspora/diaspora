class RemoveUniqueIndexOnEmailOnUsers < ActiveRecord::Migration
  def self.up
    remove_index :users, :email
    add_index :users, :email
  end

  def self.down
    remove_index :users, :email
    add_index :users, :email, :unique => true
  end
end
