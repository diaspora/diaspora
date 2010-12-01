class DeviseInvitableAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    change_table :<%= table_name %> do |t|
      t.string   :invitation_token, :limit => 20
      t.datetime :invitation_sent_at
      t.index    :invitation_token # for invitable
    end
    
    # And allow null encrypted_password and password_salt:
    change_column :<%= table_name %>, :encrypted_password, :string, :null => true
    change_column :<%= table_name %>, :password_salt,      :string, :null => true
  end
  
  def self.down
    remove_column :<%= table_name %>, :invitation_sent_at
    remove_column :<%= table_name %>, :invitation_token
  end
end
