class AddChatEnabledToAspects < ActiveRecord::Migration[4.2]
  def self.up
    add_column :aspects, :chat_enabled, :boolean, default: false
  end

  def self.down
    remove_column :aspects, :chat_enabled
  end
end
