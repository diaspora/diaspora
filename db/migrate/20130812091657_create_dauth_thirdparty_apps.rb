class CreateDauthThirdpartyApps < ActiveRecord::Migration
  def change
    create_table :dauth_thirdparty_apps do |t|
      t.string :app_id
      t.string :name
      t.string :description
      t.string :homepage_url
      t.string :dev_handle

      t.timestamps
    end
  end
end
