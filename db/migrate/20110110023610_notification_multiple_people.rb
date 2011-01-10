class NotificationMultiplePeople < ActiveRecord::Migration
  def self.up
    create_table :notification_actors do |t|
      t.integer :notifications_id
      t.integer :person_id
      t.timestamps
    end
    
    add_index :notification_actors, :notifications_id
    add_index :notification_actors, [:notifications_id, :person_id] , :unique => true
    add_index :notification_actors, :person_id  ## if i am not mistaken we don't need this one because we won't query person.notifications

    execute "INSERT INTO notification_actors (id, person_id) " +
      " SELECT id , actor_id " +
      " FROM notifications"
  end

  def self.down
    remove_index :notification_actors, :notifications_id
    remove_index :notification_actors, [:notifications_id, :person_id]
    remove_index :notification_actors, :person_id
    
    drop_table :notification_actors
  end
end
