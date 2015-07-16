class CreateOAuthApplications < ActiveRecord::Migration
  def change
    create_table :o_auth_applications do |t|
      t.belongs_to :user, index: true
      t.string :client_id
      t.string :client_secret
      t.string :name
      t.string :redirect_uris

      t.timestamps null: false
    end
  end
end
