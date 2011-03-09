class CreateConversationsAndMessagesAndVisibilities < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :conversation_id, :null => false
      t.integer :author_id, :null => false
      t.string :guid, :null => false
      t.text :text, :null => false

      t.timestamps
    end

    create_table :conversation_visibilities do |t|
      t.integer :conversation_id, :null => false
      t.integer :person_id, :null => false
      t.integer :unread, :null => false, :default => 0

      t.timestamps
    end

    create_table :conversations do |t|
      t.string :subject
      t.string :guid, :null => false
      t.integer :author_id, :null => false

      t.timestamps
    end

    add_index :conversation_visibilities, :person_id
    add_index :conversation_visibilities, :conversation_id
    add_index :conversation_visibilities, [:conversation_id, :person_id], :unique => true
    add_index :messages, :author_id
  end

  def self.down
    drop_table :messages
    drop_table :conversations
    drop_table :conversation_visibilities
  end
end
