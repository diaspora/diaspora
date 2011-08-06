class DowncaseUsernames < ActiveRecord::Migration
  class User < ActiveRecord::Base; end

  def self.up
    execute <<SQL if User.count > 0
      UPDATE users
      SET users.username = LOWER(users.username)
      WHERE users.username != LOWER(users.username)
SQL
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
