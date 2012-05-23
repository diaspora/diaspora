# This migration comes from scrypto (originally 20120520005257)
class CreateScryptoKeyRings < ActiveRecord::Migration
  def change
    create_table :scrypto_key_rings do |t|
      t.text :secured_decryption
      t.text :encryption
      t.text :secured_signing
      t.text :verification
      t.integer :owner_id
      t.string :owner_type

      t.timestamps
    end
  end
end
