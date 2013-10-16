class CreateDauthRefreshTokens < ActiveRecord::Migration
  def change
    create_table :dauth_refresh_tokens do |t|
      t.string :user_id
      t.string :app_id
      t.string :token
      t.string :secret
      t.text :scopes

      t.timestamps
    end
  end
end
