class AddUniqueIndexOnInvitationServiceAndInvitationIdentifierToUsers < ActiveRecord::Migration
  def self.up
    change_column(:users, :invitation_service, :string, :limit => 127)
    change_column(:users, :invitation_identifier, :string, :limit => 127)
    add_index(:users, [:invitation_service, :invitation_identifier], :unique => true)
  end

  def self.down
    remove_index(:users, [:invitation_service, :invitation_identifier])
  end
end
