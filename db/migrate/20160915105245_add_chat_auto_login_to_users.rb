class AddChatAutoLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :chat_auto_login, :boolean, default: false
  end
end
