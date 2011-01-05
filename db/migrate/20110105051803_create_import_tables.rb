class CreateImportTables < ActiveRecord::Migration
  def self.up
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
