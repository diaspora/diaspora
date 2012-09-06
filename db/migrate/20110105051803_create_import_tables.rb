class CreateImportTables < ActiveRecord::Migration
  def self.up
    [:aspects, :comments, :contacts, :invitations, :notifications, :people, :posts, :profiles, :requests, :services, :users].each do |table|
      add_column(table, :mongo_id, :string)
      add_index(table, :mongo_id)
    end

    add_column(:aspects, :user_mongo_id, :string)
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

    create_table :mongo_posts do |t|
      t.string :person_mongo_id
      t.boolean :public, :default => false
      t.string :diaspora_handle
      t.string :guid
      t.string :mongo_id
      t.boolean :pending, :default => false
      t.string :type

      t.text :message

      t.string :status_message_mongo_id
      t.text :caption
      t.text :remote_photo_path
      t.string :remote_photo_name
      t.string :random_string
      t.string :image #carrierwave's column
      t.text :youtube_titles

      t.timestamps
    end
    add_index :mongo_posts, :type
    add_index :mongo_posts, :person_mongo_id
    add_index :mongo_posts, :guid

    create_table :mongo_invitations do |t|
      t.string :mongo_id
      t.text :message
      t.string :sender_mongo_id
      t.string :recipient_mongo_id
      t.string :aspect_mongo_id
      t.timestamps
    end
    add_index :mongo_invitations, :sender_mongo_id
    create_table :mongo_notifications do |t|
      t.string :mongo_id
      t.string :target_type, :limit => 127
      t.string :target_mongo_id, :limit => 127
      t.string :recipient_mongo_id
      t.string :actor_mongo_id
      t.string :action
      t.boolean :unread, :default => true
      t.timestamps
    end
    add_index :mongo_notifications, [:target_type, :target_mongo_id]
    create_table :mongo_post_visibilities do |t|
      t.string :aspect_mongo_id
      t.string :post_mongo_id
      t.timestamps
    end
    add_index :mongo_post_visibilities, :aspect_mongo_id
    add_index :mongo_post_visibilities, :post_mongo_id

    create_table :mongo_profiles do |t|
      t.string :diaspora_handle
      t.string :first_name, :limit => 127
      t.string :last_name, :limit => 127
      t.string :image_url
      t.string :image_url_small
      t.string :image_url_medium
      t.date :birthday
      t.string :gender
      t.text :bio
      t.boolean :searchable, :default => true
      t.string :person_mongo_id
      t.timestamps
    end
    add_index :mongo_profiles, [:first_name, :searchable]
    add_index :mongo_profiles, [:last_name, :searchable]
    add_index :mongo_profiles, [:first_name, :last_name, :searchable]
    add_index :mongo_profiles, :person_mongo_id, :unique => true


    create_table :mongo_requests do |t|
      t.string :mongo_id
      t.string :sender_mongo_id, :limit => 127
      t.string :recipient_mongo_id, :limit => 127
      t.string :aspect_mongo_id
      t.timestamps
    end
    add_index :mongo_requests, :sender_mongo_id
    add_index :mongo_requests, :recipient_mongo_id
    add_index :mongo_requests, [:sender_mongo_id, :recipient_mongo_id], :unique => true

    add_column(:services, :user_mongo_id, :string)
    create_table :mongo_services do |t|
      t.string :mongo_id
      t.string :type
      t.string :user_mongo_id
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :access_secret
      t.string :nickname
      t.timestamps
    end
    add_index :mongo_services, :user_mongo_id

    create_table :mongo_users do |t|
      t.string :username
      t.text :serialized_private_key
      t.integer :invites
      t.boolean :getting_started
      t.boolean :disable_mail
      t.string :language
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip


      t.timestamps
      t.string :mongo_id
    end
    add_index :mongo_users, :mongo_id, :unique => true
  end

  def self.down
    execute 'DROP TABLE mongo_users'
    execute 'DROP TABLE mongo_services'
    execute 'DROP TABLE mongo_requests'
    execute 'DROP TABLE mongo_post_visibilities'
    execute 'DROP TABLE mongo_invitations'
    execute 'DROP TABLE mongo_contacts'
    execute 'DROP TABLE mongo_comments'
    execute 'DROP TABLE mongo_profiles'
    execute 'DROP TABLE mongo_people'
    execute 'DROP TABLE mongo_posts'
    execute 'DROP TABLE mongo_aspect_memberships'
    execute 'DROP TABLE mongo_aspects'
  end
end
