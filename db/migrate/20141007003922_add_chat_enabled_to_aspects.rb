class AddChatEnabledToAspects < ActiveRecord::Migration
  def self.up
    add_column :aspects, :chat_enabled, :boolean, default: false
  end

  def self.down
    remove_column :aspects, :chat_enabled
  end
end
