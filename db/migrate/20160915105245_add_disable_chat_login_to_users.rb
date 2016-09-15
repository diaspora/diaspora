class AddDisableChatLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disable_chat_login, :boolean, default: false
  end
end
