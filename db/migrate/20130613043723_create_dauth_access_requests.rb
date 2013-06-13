class CreateDauthAccessRequests < ActiveRecord::Migration
  def change
    create_table :dauth_access_requests do |t|
      t.string :auth_token, :unique => true, :null => false
      t.string :dev_handle, :null => false
      t.string :callback_url, :null => false
      t.string :redirect_url, :null => false
      t.text :scopes, :null => false
      t.string :app_id, :null => false
      t.string :app_name
      t.string :app_description
      t.string :app_version

      t.timestamps
    end
  end
end
