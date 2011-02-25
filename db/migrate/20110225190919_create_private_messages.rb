class CreatePrivateMessages < ActiveRecord::Migration
  def self.up
    create_table :private_messages do |t|
      t.integer :author_id, :null => false
      t.boolean :unread, :null => false, :default => true
      t.string :guid, :null => false
      t.text :message, :null => false

      t.timestamps
    end

    add_index :private_messages, :author_id
  end

  def self.down
    drop_table :private_messages
  end
end
