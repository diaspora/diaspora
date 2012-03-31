class RemoveInvitationEmailFromUsers < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      UPDATE users
      SET email = 'invitemail_' || id || '@example.org'
      WHERE invitation_token IS NOT NULL
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE users
      SET email = (SELECT identifier FROM invitations WHERE invitations.recipient_id = users.id)
      WHERE invitation_token IS NOT NULL
    SQL
  end
end
