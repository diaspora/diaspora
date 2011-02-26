class CreatePrivateMessagesAndVisibilities < ActiveRecord::Migration
  def self.up
    create_table :private_messages do |t|
      t.integer :author_id, :null => false
      t.string :guid, :null => false
      t.text :message, :null => false

      t.timestamps
    end


    create_table :private_message_visibilities do |t|
      t.integer :private_message_id
      t.integer :person_id
      t.boolean :unread, :null => false, :default => true

      t.timestamps
    end

    add_index :private_message_visibilities, :person_id
    add_index :private_message_visibilities, :private_message_id
    add_index :private_message_visibilities, [:private_message_id, :person_id], :name => 'pm_visibilities_on_pm_id_and_person_id', :unique => true
    add_index :private_messages, :author_id
  end

  def self.down
    drop_table :private_messages
    drop_table :private_message_visibilities
  end
end
