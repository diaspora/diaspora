# Inspired by https://github.com/nov/openid_connect_sample/blob/master/db/migrate/20110829023837_create_access_tokens.rb

class CreateOAuthAccessTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :o_auth_access_tokens do |t|
      t.belongs_to :authorization, index: true
      t.string :token, index: {unique: true, length: 191}
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_foreign_key :o_auth_access_tokens, :authorizations
  end
end
