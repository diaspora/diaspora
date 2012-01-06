class DropMongoRemains < ActiveRecord::Migration
  def self.up
    remove_index :aspects, :mongo_id
    remove_index :comments, :mongo_id
    remove_index :contacts, :mongo_id
    remove_index :invitations, :mongo_id
    remove_index :people, :mongo_id
    remove_index :posts, :mongo_id
    remove_index :profiles, :mongo_id
    remove_index :services, :mongo_id
    remove_index :users, :mongo_id

    execute 'DROP TABLE mongo_notifications'
  end

  def self.down
  end
end
