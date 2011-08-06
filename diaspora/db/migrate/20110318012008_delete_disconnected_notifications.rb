class DeleteDisconnectedNotifications < ActiveRecord::Migration
  def self.up
    result = execute("SELECT notifications.id FROM notifications
            LEFT OUTER JOIN posts ON posts.id = notifications.target_id
            WHERE posts.id IS NULL AND notifications.target_id IS NOT NULL AND notifications.target_type = 'Post'").to_a.flatten!
    execute("DELETE FROM notifications WHERE notifications.id IN (#{result.join(',')})") if result
  end

  def self.down
  end
end
