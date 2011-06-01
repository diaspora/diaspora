class AddConfirmEmailTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :confirm_email_token, :string, :limit => 30
  end

  def self.down
    remove_column :users, :confirm_email_token
  end
end
