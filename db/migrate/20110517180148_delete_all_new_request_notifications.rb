class DeleteAllNewRequestNotifications < ActiveRecord::Migration
  def self.up
    execute <<SQL
      DELETE notifications.* FROM notifications
      WHERE notifications.type = 'Notifications::NewRequest'
        OR notifications.type = 'Notifications::RequestAccepted'
SQL
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
