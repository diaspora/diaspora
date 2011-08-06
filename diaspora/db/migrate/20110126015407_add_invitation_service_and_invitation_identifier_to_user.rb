class AddInvitationServiceAndInvitationIdentifierToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :invitation_service, :string)
    add_column(:users, :invitation_identifier, :string)

    execute("UPDATE users SET invitation_service='email', invitation_identifier= email WHERE invitation_token IS NOT NULL;")
  end

  def self.down
    remove_column(:users, :invitation_service, :string)
    remove_column(:users, :invitation_identifier, :string)
  end
end
