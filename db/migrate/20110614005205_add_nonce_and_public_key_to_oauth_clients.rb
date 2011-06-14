class AddNonceAndPublicKeyToOauthClients < ActiveRecord::Migration
  def self.up
    add_column :oauth_clients, :nonce, :string
    add_column :oauth_clients, :public_key, :text
    add_index :oauth_clients, :nonce
  end

  def self.down
    remove_column :oauth_clients, :nonce
    remove_column :oauth_clients, :public_key
    remove_index :oauth_clients, :nonce
  end
end
