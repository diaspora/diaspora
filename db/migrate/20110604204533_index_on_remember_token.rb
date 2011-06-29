class IndexOnRememberToken < ActiveRecord::Migration
  def self.up
    add_index :users, :remember_token, :unique => true
  end

  def self.down
    remove_index :users, :column => :remember_token
  end
end
