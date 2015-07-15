class CreateIdTokens < ActiveRecord::Migration
  def change
    create_table :id_tokens do |t|
      t.belongs_to :authorization, index: true
      t.datetime :expires_at
      t.string :nonce

      t.timestamps null: false
    end
  end
end
