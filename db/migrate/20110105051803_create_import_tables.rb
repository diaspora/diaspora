class CreateImportTables < ActiveRecord::Migration
  def self.up
    create_table :mongo_aspects do |t|
      t.string :mongo_id
      t.string :name
      t.string :user_mongo_id
      t.timestamps
    end
    add_index :mongo_aspects, :user_mongo_id

    create_table :mongo_aspect_memberships do |t|
      t.string :aspect_mongo_id
      t.string :contact_mongo_id
      t.timestamps
    end
    add_index :mongo_aspect_memberships, :aspect_mongo_id
    add_index :mongo_aspect_memberships, :contact_mongo_id

    create_table :mongo_users do |t|
      t.string :mongo_id
      t.string :username
      t.text :serialized_private_key
      t.string :encrypted_password
      t.integer :invites
      t.string :invitation_token
      t.datetime :invitation_sent_at
      t.boolean :getting_started
      t.boolean :disable_mail
      t.string :language
      t.string :last_sign_in_ip
      t.datetime :last_sign_in_at
      t.string :reset_password_token
      t.string :password_salt
    end
  end

  def self.down
    drop_table :mongo_users
  end
end
