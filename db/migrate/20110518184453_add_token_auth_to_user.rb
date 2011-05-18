class AddTokenAuthToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :authentication_token, :string, :limit => 30)
    add_index(:users, :authentication_token, :unique => true)
  end

  def self.down
    remove_index(:users, :column => :authentication_token)
    remove_column(:users, :authentication_token)
  end
end
