class CreateOauthClientBlocks < ActiveRecord::Migration

  def self.up
    create_table 'oauth_client_blocks', :force => true do |t|
      t.integer  'client_id', :null => false
      t.integer  'user_id', :null => false
      t.timestamps
    end

    add_index 'oauth_client_blocks', ['client_id', 'user_id'], :unique => true, :name => 'index_oauth_client_blocks_on_client_id_and_user_id'
  end

  def self.down
    remove_index 'oauth_client_blocks', :name => 'index_oauth_client_blocks_on_client_id_and_user_id'

    drop_table 'oauth_client_blocks'
  end

end
