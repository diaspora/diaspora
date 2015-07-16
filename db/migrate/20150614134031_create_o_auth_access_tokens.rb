class CreateOAuthAccessTokens < ActiveRecord::Migration
  def change
    create_table :o_auth_access_tokens do |t|
      t.belongs_to :authorization, index: true
      t.string :token
      t.datetime :expires_at

      t.timestamps null: false
    end
  end
end
