class AddUniqueIndexOnInvitationServiceAndInvitationIdentifierToUsers < ActiveRecord::Migration
  def self.up
    add_index(:users, [:invitation_service, :invitation_identifier], :unique => true)
  end

  def self.down
    remove_index(:users, [:invitation_service, :invitation_identifier])
  end
end
