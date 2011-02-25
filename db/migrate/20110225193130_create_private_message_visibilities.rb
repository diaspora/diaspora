class CreatePrivateMessageVisibilities < ActiveRecord::Migration
  def self.up
    create_table :private_message_visibilities do |t|
      t.integer :private_message_id
      t.integer :person_id

      t.timestamps
    end

    add_index :private_message_visibilities, :person_id
    add_index :private_message_visibilities, :private_message_id
    add_index :private_message_visibilities, [:private_message_id, :person_id], :name => 'pm_visibilities_on_pm_id_and_person_id', :unique => true
  end

  def self.down
    drop_table :private_message_visibilities
  end
end
