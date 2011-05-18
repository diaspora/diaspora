class DisablePasswordResetForAccountsWithoutUsernames < ActiveRecord::Migration
  def self.up
    execute <<SQL
      UPDATE users
        SET email = ""
      WHERE username IS NULL
        AND invitation_identifier IS NOT NULL
        AND invitation_service = 'email'
SQL
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
