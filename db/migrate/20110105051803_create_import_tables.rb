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

    create_table :mongo_comments do |t|
      t.text :text
      t.string :mongo_id
      t.string :post_mongo_id
      t.string :person_mongo_id
      t.string :guid
      t.text :creator_signature
      t.text :post_creator_signature
      t.text :youtube_titles
      t.timestamps
    end
    add_index :mongo_comments, :guid, :unique => true
    add_index :mongo_comments, :post_mongo_id

    create_table :mongo_contacts do |t|
      t.string :mongo_id
      t.string :user_mongo_id
      t.string :person_mongo_id
      t.boolean :pending, :default => true
      t.timestamps
    end

    add_index :mongo_contacts, [:user_mongo_id, :pending]
    add_index :mongo_contacts, [:person_mongo_id, :pending]
    create_table :mongo_people do |t|
      t.string :mongo_id
      t.string :guid
      t.text :url
      t.string :diaspora_handle
      t.text :serialized_public_key
      t.string :owner_mongo_id
      t.timestamps
    end
    add_index :mongo_people, :guid, :unique => true
    add_index :mongo_people, :owner_mongo_id, :unique => true
    add_index :mongo_people, :diaspora_handle, :unique => true

    create_table :mongo_invitations do |t|
      t.string :mongo_id
      t.text :message
      t.string :sender_mongo_id
      t.string :recipient_mongo_id
      t.string :aspect_mongo_id
      t.timestamps
    end
    add_index :mongo_invitations, :sender_mongo_id

    create_table :mongo_post_visibilities do |t|
      t.string :aspect_mongo_id
      t.string :post_mongo_id
      t.timestamps
    end
    add_index :mongo_post_visibilities, :aspect_mongo_id
    add_index :mongo_post_visibilities, :post_mongo_id

    create_table :mongo_requests do |t|
      t.string :mongo_id
      t.string :sender_mongo_id
      t.string :recipient_mongo_id
      t.string :aspect_mongo_id
      t.timestamps
    end
    add_index :mongo_requests, :sender_mongo_id
    add_index :mongo_requests, :recipient_mongo_id
    add_index :mongo_requests, [:sender_mongo_id, :recipient_mongo_id]

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
    drop_table :mongo_requests
    drop_table :mongo_post_visibilities
    drop_table :mongo_contacts
    drop_table :mongo_comments
    drop_table :mongo_aspect_memberships
    drop_table :mongo_aspects
  end
end
