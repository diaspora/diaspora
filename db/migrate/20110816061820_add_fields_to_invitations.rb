class AddFieldsToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :service, :string
    add_column :invitations, :identifier, :string
    add_column :invitations, :admin, :boolean, :default => false
    change_column :invitations, :recipient_id, :integer, :null => true
    change_column :invitations, :sender_id, :integer, :null => true
  end

  def self.down
    remove_column :invitations, :service
    remove_column :invitations, :identifier
    remove_column :invitations, :admin
    change_column :invitations, :recipient_id, :integer, :null => false
    change_column :invitations, :sender_id, :integer, :null => false
  end
end
