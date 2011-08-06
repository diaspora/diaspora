class AddOAuth2Support < ActiveRecord::Migration
  def self.up
    create_table 'oauth_clients', :force => true do |t|
      t.string   'name',                 :limit => 127, :null => false
      t.text     'description',                         :null => false
      t.string   'application_base_url', :limit => 127, :null => false
      t.string   'icon_url',             :limit => 127, :null => false

      t.string   'oauth_identifier',     :limit => 32,  :null => false
      t.string   'oauth_secret',         :limit => 32,  :null => false
      t.string   'nonce',                :limit => 64
      t.text     'public_key',                          :null => false
      t.text     'permissions_overview',                :null => false
    end

    add_index :oauth_clients, :name, :unique => true
    add_index :oauth_clients, :application_base_url, :unique => true
    add_index :oauth_clients, :nonce, :unique => true

    create_table 'oauth_authorization_codes', :force => true do |t|
      t.integer  'authorization_id',    :null => false
      t.string   'code',  :limit => 32, :null => false
      t.datetime 'expires_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.string   'redirect_uri'
    end

    create_table 'oauth_authorizations', :force => true do |t|
      t.integer  'client_id', :null => false
      t.integer  'resource_owner_id'
      t.string   'resource_owner_type', :limit => 32
      t.string   'scope'
      t.datetime 'expires_at'
    end

    create_table 'oauth_access_tokens', :force => true do |t|
      t.integer  'authorization_id',            :null => false
      t.string   'access_token',  :limit => 32, :null => false
      t.string   'refresh_token', :limit => 32
      t.datetime 'expires_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index "oauth_authorizations", ["resource_owner_id", "resource_owner_type", "client_id"], :unique => true, :name => "index_oauth_authorizations_on_resource_owner_and_client_id"
  end

  def self.down
    remove_index "oauth_authorizations", :name => "index_oauth_authorizations_on_resource_owner_and_client_id"

    drop_table 'oauth_access_tokens'

    drop_table 'oauth_authorizations'

    drop_table 'oauth_authorization_codes'

    remove_index :oauth_clients, :column => :nonce
    remove_index :oauth_clients, :column => :application_base_url
    remove_index :oauth_clients, :column => :name

    drop_table 'oauth_clients'
  end

end
