class AddIndicies < ActiveRecord::Migration
  def self.up
    add_index :comments, :person_id

    add_index :invitations, :recipient_id
    add_index :invitations, :aspect_id

    add_index :notifications, :target_id
    add_index :notifications, :recipient_id

    add_index :posts, :status_message_id
    add_index :posts, [:status_message_id, :pending]
    add_index :posts, [:type, :pending, :id]
  end

  def self.down
    remove_index :comments, :person_id

    remove_index :invitations, :recipient_id
    remove_index :invitations, :aspect_id

    remove_index :notifications, :target_id
    remove_index :notifications, :recipient_id

    remove_index :posts, :status_message_id
    remove_index :posts, [:status_message_id, :pending]
    remove_index :posts, [:type, :pending, :id]
  end
end
