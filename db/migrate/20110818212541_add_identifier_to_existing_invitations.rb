class AddIdentifierToExistingInvitations < ActiveRecord::Migration
  class Invitation < ActiveRecord::Base; end
  def self.up
    execute <<SQL unless Invitation.count == 0
    UPDATE invitations
      SET invitations.identifier = (SELECT users.invitation_identifier  FROM users WHERE users.id = invitations.recipient_id),
          invitations.service = (SELECT users.invitation_service FROM users WHERE users.id = invitations.recipient_id)
      WHERE invitations.identifier IS NULL
SQL
  end

  def self.down
    execute <<SQL unless Invitation.count == 0
    UPDATE invitations
      SET invitations.identifier = NULL,
          invitations.service = NULL
      WHERE (SELECT users.invitation_identifier  FROM users WHERE users.id = invitations.recipient_id) IS NOT NULL
SQL
  end
end
