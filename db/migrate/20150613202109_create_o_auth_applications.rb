class CreateOAuthApplications < ActiveRecord::Migration
  def change
    create_table :o_auth_applications do |t|
      t.belongs_to :user, index: true
      t.string :client_id
      t.string :client_secret
      t.string :client_name
      t.string :redirect_uris
      t.string :response_types
      t.string :grant_types
      t.string :application_type
      t.string :contacts
      t.string :logo_uri
      t.string :client_uri
      t.string :policy_uri
      t.string :tos_uri

      t.timestamps null: false
    end
  end
end
