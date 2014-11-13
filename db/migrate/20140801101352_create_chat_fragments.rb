class CreateChatFragments < ActiveRecord::Migration
  def up
    create_table :chat_fragments do |t|
      t.integer :user_id, null: false
      t.string :root, limit: 256, null: false
      t.string :namespace, limit: 256, null: false
      t.text :xml, null: false
    end
    # That'll wont work due UTF-8 and the limit of 767 bytes
    #add_index :chat_fragments, [:user_id, :root, :namespace], unique: true
    add_index :chat_fragments, [:user_id], unique: true
  end

  def down
    drop_table :chat_fragments
  end
end
