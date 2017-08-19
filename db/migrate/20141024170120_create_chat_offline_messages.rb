class CreateChatOfflineMessages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :chat_offline_messages do |t|
      t.string :from, :null => false
      t.string :to, :null => false
      t.text :message, :null => false
      t.datetime "created_at", :null => false
    end
  end

  def self.down
    drop_table :chat_offline_messages
  end
end
