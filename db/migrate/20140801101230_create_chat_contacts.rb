class CreateChatContacts < ActiveRecord::Migration
  def up
    create_table :chat_contacts do |t|
      t.integer :user_id, null: false
      t.string :jid, null: false
      t.string :name, limit: 255, null: true
      t.string :ask, limit: 128, null: true
      t.string :subscription, limit: 128, null: false
    end
    add_index :chat_contacts, [:user_id, :jid], unique: true
  end

  def down
    drop_table :chat_contacts
  end
end
