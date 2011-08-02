class AddAccountTable < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |table|
      table.string :login, :null => false
      table.string :password, :null => false
    end
  end

  def self.down
    drop_table :accounts
  end
end
