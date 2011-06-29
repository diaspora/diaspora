class DisablePasswordResetForAccountsWithoutUsernames < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  def self.up
    execute <<SQL if User.count > 0
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
