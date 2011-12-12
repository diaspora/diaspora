class AddOauthRedirectUriToOauthClients < ActiveRecord::Migration
  def self.up
    add_column :oauth_clients, :oauth_redirect_uri, :string
  end

  def self.down
    remove_column :oauth_clients, :oauth_redirect_uri
  end
end
