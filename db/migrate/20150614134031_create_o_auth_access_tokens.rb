class CreateOAuthAccessTokens < ActiveRecord::Migration
  def self.up
    create_table :o_auth_access_tokens do |t|
      t.belongs_to :user, index: true
      t.belongs_to :authorizations
      t.belongs_to :endpoints
      t.string :token
      t.datetime :expires_at

      t.timestamps null: false
    end
  end
end
