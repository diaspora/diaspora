class CreateDauthAccessTokens < ActiveRecord::Migration
  def change
    create_table :dauth_access_tokens do |t|
      t.string :refresh_token_id
      t.string :token
      t.string :secret
      t.datetime :expire_at

      t.timestamps
    end
  end
end
