class AddClosedAccountFlagToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :closed_account, :boolean, :default => false
  end

  def self.down
    remove_column :people, :closed_account
  end
end
