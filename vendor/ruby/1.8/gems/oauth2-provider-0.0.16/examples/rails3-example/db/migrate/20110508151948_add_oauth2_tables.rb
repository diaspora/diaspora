class AddOauth2Tables < ActiveRecord::Migration
  def self.up
    create_table 'oauth_clients', :force => true do |t|
      t.string   'name'
      t.string   'oauth_identifier', :null => false
      t.string   'oauth_secret', :null => false
    end

    create_table 'oauth_authorization_codes', :force => true do |t|
      t.integer  'authorization_id', :null => false
      t.string   'code',      :null => false
      t.datetime 'expires_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.string   'redirect_uri'
    end

    create_table 'oauth_authorizations', :force => true do |t|
      t.integer  'client_id', :null => false
      t.integer  'resource_owner_id'
      t.string   'resource_owner_type'
      t.string   'scope'
      t.datetime 'expires_at'
    end

    create_table 'oauth_access_tokens', :force => true do |t|
      t.integer  'authorization_id', :null => false
      t.string   'access_token', :null => false
      t.string   'refresh_token'
      t.datetime 'expires_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end

  def self.down
    drop_table 'example_resource_owners'
    drop_table 'oauth_access_tokens'
    drop_table 'oauth_authorizations'
    drop_table 'oauth_authorization_codes'
    drop_table 'oauth_clients'
  end
end
