class AddFieldsToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :service, :string
    add_column :invitations, :identifier, :string
  end

  def self.down
    remove_column :invitations, :service
    remove_column :invitations, :identifier
  end
end
