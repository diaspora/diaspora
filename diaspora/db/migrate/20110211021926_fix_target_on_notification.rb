class FixTargetOnNotification < ActiveRecord::Migration
  def self.up
    note_ids = execute('select id from notifications').to_a
    unless note_ids.empty?
      execute("UPDATE notifications " +
  "SET target_type='Post' " +
  "WHERE action = 'comment_on_post' OR action = 'also_commented'")

      execute("UPDATE notifications " +
  "SET target_type='Request' " +
  "WHERE action = 'new_request' OR action = 'request_accepted'")

      execute("UPDATE notifications " +
  "SET target_type='Mention' " +
  "WHERE action = 'mentioned'")

      execute("create temporary table t1 "+
      "(select notifications.id as n_id " +
      "from notifications LEFT JOIN mentions "+
      "ON notifications.target_id = mentions.id  "+
      "WHERE notifications.action = 'mentioned' AND mentions.id IS NULL)")

      execute("DELETE notifications.* FROM notifications, t1 WHERE notifications.id = t1.n_id")
    end
  end

  def self.down
  end
end
