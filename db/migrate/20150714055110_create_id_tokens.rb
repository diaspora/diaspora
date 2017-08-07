# Inspired by https://github.com/nov/openid_connect_sample/blob/master/db/migrate/20110829024010_create_id_tokens.rb

class CreateIdTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :id_tokens do |t|
      t.belongs_to :authorization, index: true
      t.datetime :expires_at
      t.string :nonce

      t.timestamps null: false
    end
    add_foreign_key :id_tokens, :authorizations
  end
end
