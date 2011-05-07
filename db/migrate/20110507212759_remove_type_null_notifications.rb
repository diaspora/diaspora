class RemoveTypeNullNotifications < ActiveRecord::Migration
  def self.up
    execute <<SQL
      DELETE FROM notifications
      WHERE type IS NULL
SQL
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end

