class CreateManifests < ActiveRecord::Migration
  def change
    create_table :manifests do |t|
      t.integer :dev_id
      t.string :app_id
      t.string :app_description
      t.string :app_name
      t.string :app_version
      t.string :manifest_ver
      t.string :callback_url
      t.string :redirect_url
      t.text :signed_jwt
      t.text :scopes

      t.timestamps
    end
  end
end
