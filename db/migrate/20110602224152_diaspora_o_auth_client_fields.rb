class DiasporaOAuthClientFields < ActiveRecord::Migration
  def self.up
    add_column :oauth_clients, :description, :text
    add_column :oauth_clients, :homepage_url, :string
    add_column :oauth_clients, :icon_url, :string
  end

  def self.down
    remove_column :oauth_clients, :icon_url
    remove_column :oauth_clients, :homepage_url
    remove_column :oauth_clients, :description
  end
end
