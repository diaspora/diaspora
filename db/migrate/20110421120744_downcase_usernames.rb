class DowncaseUsernames < ActiveRecord::Migration
  def self.up
    execute <<SQL
      UPDATE users
      SET users.username = LOWER(users.username)
      WHERE users.username != LOWER(users.username)
SQL
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
