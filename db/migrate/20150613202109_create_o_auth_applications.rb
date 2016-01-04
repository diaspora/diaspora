# Inspired by https://github.com/nov/openid_connect_sample/blob/master/db/migrate/20110829023826_create_clients.rb

class CreateOAuthApplications < ActiveRecord::Migration
  def change
    create_table :o_auth_applications do |t|
      t.belongs_to :user, index: true
      t.string :client_id, index: {unique: true, length: 191}
      t.string :client_secret
      t.string :client_name

      t.text :redirect_uris
      t.string :response_types
      t.string :grant_types
      t.string :application_type, default: "web"
      t.string :contacts
      t.string :logo_uri
      t.string :client_uri
      t.string :policy_uri
      t.string :tos_uri
      t.string :sector_identifier_uri
      t.string :token_endpoint_auth_method
      t.text :jwks
      t.string :jwks_uri
      t.boolean :ppid, default: false

      t.timestamps null: false
    end
    add_foreign_key :o_auth_applications, :users
  end
end
