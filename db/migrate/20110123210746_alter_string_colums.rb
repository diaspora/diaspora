class AlterStringColumns < ActiveRecord::Migration
    # This alters the tables to avoid a mysql bug
    # See http://bugs.joindiaspora.com/issues/835
    def self.up
        remove_index :profiles, :column => [:first_name, :searchable]
        remove_index :profiles, :column => [:last_name, :searchable]
        remove_index :profiles, :column => [:first_name, :last_name, :searchable]
        change_column(:profiles, :first_name, :string, :limit => 127)
        change_column(:profiles, :last_name, :string, :limit => 127)
        add_index :profiles, [:first_name, :searchable]
        add_index :profiles, [:last_name, :searchable]
        add_index :profiles, [:first_name, :last_name, :searchable]

        remove_index :mongo_notifications, :column => [:target_type, :target_mongo_id]
        change_column(:mongo_notifications, :target_type, :string, :limit => 127)
        change_column(:mongo_notifications, :target_mongo_id, :string, :limit => 127)
        add_index :mongo_notifications, [:target_type, :target_mongo_id]

        remove_index :mongo_profiles, :column => [:first_name, :searchable]
        remove_index :mongo_profiles, :column => [:last_name, :searchable]
        remove_index :mongo_profiles, :column => [:first_name, :last_name, :searchable]
        change_column(:mongo_profiles, :first_name, :string, :limit => 127)
        change_column(:mongo_profiles, :last_name, :string, :limit => 127)
        add_index :mongo_profiles, [:first_name, :searchable]
        add_index :mongo_profiles, [:last_name, :searchable]
        add_index :mongo_profiles, [:first_name, :last_name, :searchable]

        remove_index :mongo_requests, :column => :sender_mongo_id
        remove_index :mongo_requests, :column => :recipient_mongo_id
        remove_index :mongo_requests, :column => [:sender_mongo_id, :recipient_mongo_id]
        change_column(:mongo_requests, :sender_mongo_id, :string, :limit => 127)
        change_column(:mongo_requests, :recipient_mongo_id, :string, :limit => 127)
        add_index :mongo_requests, :sender_mongo_id
        add_index :mongo_requests, :recipient_mongo_id
        add_index :mongo_requests, [:sender_mongo_id, :recipient_mongo_id], :unique => true
    end
end
