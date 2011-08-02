class DeviseInvitableAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    change_table :<%= table_name %> do |t|
      t.string     :invitation_token, :limit => 60
      t.datetime   :invitation_sent_at
      t.integer    :invitation_limit
      t.references :invited_by, :polymorphic => true
      t.index      :invitation_token # for invitable
      t.index      :invited_by_id
    end
    
    # And allow null encrypted_password and password_salt:
    change_column_null :<%= table_name %>, :encrypted_password, true
<% if class_name.constantize.columns_hash['password_salt'] -%>
    change_column_null :<%= table_name %>, :password_salt,      true
<% end -%>
  end
  
  def self.down
    change_table :<%= table_name %> do |t|
      t.remove_references :invited_by, :polymorphic => true
      t.remove :invitation_limit, :invitation_sent_at, :invitation_token
    end
  end
end
