class AddUnconfirmedEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unconfirmed_email, :string, :default => nil, :null => true
  end

  def self.down
    remove_column :users, :unconfirmed_email
  end
end
