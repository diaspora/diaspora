class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :aspects do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
    add_index :aspects, :user_id

    create_table :aspect_memberships do |t|
      t.integer :aspect_id
      t.integer :contact_id
      t.timestamps
    end
    add_index :aspect_memberships, :aspect_id
    add_index :aspect_memberships, [:aspect_id, :contact_id], :unique => true
    add_index :aspect_memberships, :contact_id

    create_table :comments do |t|
      t.text :text
      t.integer :post_id
      t.integer :person_id
      t.string :guid
      t.text :creator_signature
      t.text :post_creator_signature
      t.text :youtube_titles
      t.timestamps
    end
    add_index :comments, :guid, :unique => true
    add_index :comments, :post_id

    create_table :contacts do |t|
      t.integer :user_id
      t.integer :person_id
      t.boolean :pending, :default => true
      t.timestamps
    end
    add_index :contacts, [:user_id, :pending]
    add_index :contacts, [:person_id, :pending]
    add_index :contacts, [:user_id, :person_id], :unique => true

    create_table :invitations do |t|
      t.text :message
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :aspect_id
      t.timestamps
    end
    add_index :invitations, :sender_id

    create_table :notifications do |t|
      t.string :target_type
      t.integer :target_id
      t.integer :recipient_id
      t.integer :actor_id
      t.string :action
      t.boolean :unread, :default => true
      t.timestamps
    end
    add_index :notifications, [:target_type, :target_id]

    create_table :people do |t|
      t.string :guid
      t.text :url
      t.string :diaspora_handle
      t.text :serialized_public_key
      t.integer :owner_id
      t.timestamps
    end
    add_index :people, :guid, :unique => true
    add_index :people, :owner_id, :unique => true
    add_index :people, :diaspora_handle, :unique => true

    create_table :posts do |t|
      t.integer :person_id
      t.boolean :public, :default => false
      t.string :diaspora_handle
      t.string :guid
      t.boolean :pending, :default => false
      t.string :type

      t.text :message

      t.integer :status_message_id
      t.text :caption
      t.text :remote_photo_path
      t.string :remote_photo_name
      t.string :random_string
      t.string :image #carrierwave's column
      t.text :youtube_titles

      t.timestamps
    end
    add_index :posts, :type
    add_index :posts, :person_id
    add_index :posts, :guid

    create_table :post_visibilities do |t|
      t.integer :aspect_id
      t.integer :post_id
      t.timestamps
    end
    add_index :post_visibilities, :aspect_id
    add_index :post_visibilities, :post_id

    create_table :profiles do |t|
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
      t.integer :person_id
      t.timestamps
    end
    add_index :profiles, [:first_name, :searchable]
    add_index :profiles, [:last_name, :searchable]
    add_index :profiles, [:first_name, :last_name, :searchable]
    add_index :profiles, :person_id

    create_table :requests do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :aspect_id
      t.timestamps
    end
    add_index :requests, :sender_id
    add_index :requests, :recipient_id
    add_index :requests, [:sender_id, :recipient_id], :unique => true

    create_table :services do |t|
      t.string :type, :limit => 127
      t.integer :user_id
      t.string :provider
      t.string :uid, :limit => 127
      t.string :access_token
      t.string :access_secret
      t.string :nickname
      t.timestamps
    end
    add_index :services, :user_id

    create_table :users do |t|
      t.string :username
      t.text :serialized_private_key
      t.integer :invites, :default => 0
      t.boolean :getting_started, :default => true
      t.boolean :disable_mail, :default => false
      t.string :language

      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      t.string   :invitation_token, :limit => 60
      t.datetime :invitation_sent_at

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps
    end
    add_index :users, :username, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :invitation_token

  end

  def self.down
    raise "irreversable migration!"
  end
end
