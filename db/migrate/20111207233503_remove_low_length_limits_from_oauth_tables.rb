class RemoveLowLengthLimitsFromOauthTables < ActiveRecord::Migration
  def self.up
    change_column :oauth_clients, :oauth_identifier, :string, :limit => 127
    change_column :oauth_clients, :oauth_secret, :string, :limit => 127
    change_column :oauth_clients, :nonce, :string, :limit => 127
    change_column :oauth_authorization_codes, :code, :string, :limit => 127
    change_column :oauth_access_tokens, :access_token, :string, :limit => 127
    change_column :oauth_access_tokens, :refresh_token, :string, :limit => 127
  end

  def self.down
    change_column :oauth_clients, :oauth_identifier, :string, :limit => 32
    change_column :oauth_clients, :oauth_secret, :string, :limit => 32
    change_column :oauth_clients, :nonce, :string, :limit => 64
    change_column :oauth_authorization_codes, :code, :string, :limit => 32
    change_column :oauth_access_tokens, :access_token, :string, :limit => 32
    change_column :oauth_access_tokens, :refresh_token, :string, :limit => 32
  end
end
