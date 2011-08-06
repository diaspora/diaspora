class DeleteAllNewRequestNotifications < ActiveRecord::Migration
  class Notification < ActiveRecord::Base; end
  def self.up
    execute <<SQL if Notification.count > 0
      DELETE notifications.* FROM notifications
      WHERE notifications.type = 'Notifications::NewRequest'
        OR notifications.type = 'Notifications::RequestAccepted'
SQL
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
