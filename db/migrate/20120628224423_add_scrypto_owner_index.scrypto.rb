# This migration comes from scrypto (originally 20120628221855)
class AddScryptoOwnerIndex < ActiveRecord::Migration
  def change
    add_index :scrypto_key_rings, :owner_id, :unique => true
  end
end
