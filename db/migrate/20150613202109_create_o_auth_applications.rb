class CreateOAuthApplications < ActiveRecord::Migration
  def change
    create_table :o_auth_applications do |t|
      t.string :client_id
      t.string :client_secret

      t.timestamps null: false
    end
  end
end
