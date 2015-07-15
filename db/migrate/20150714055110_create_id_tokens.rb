class CreateIdTokens < ActiveRecord::Migration
  def change
    create_table :id_tokens do |t|
      t.belongs_to :user, index: true
      t.belongs_to :o_auth_application, index: true
      t.datetime :expires_at
      t.string :nonce

      t.timestamps null: false
    end
  end
end
