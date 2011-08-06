class EliminateStrayUserRecords < ActiveRecord::Migration
  class User < ActiveRecord::Base; end

  def self.up
    return unless User.count > 0
    duplicated_emails = execute("SELECT LOWER(email) from users WHERE users.email != '' GROUP BY LOWER(email) HAVING COUNT(*) > 1").to_a
    duplicated_emails.each do |email|
      records = execute("SELECT users.id, users.username, users.created_at from users WHERE LOWER(users.email) = '#{email}'").to_a
      with_username = records.select { |r| !r[1].blank? }
      if with_username.length == 1
        execute("DELETE FROM users WHERE LOWER(users.email) = '#{email}' AND users.username IS NULL")
      end
      if with_username.length == 0 && !email.blank?
        newest_record = records.sort_by{|r| r[2].to_i}.last
        execute("DELETE FROM users WHERE LOWER(users.email) = '#{email}' AND users.id != #{newest_record[0]}")
      end
    end
    execute <<SQL
      UPDATE users
      SET users.username = LOWER(users.username)
      WHERE users.username != LOWER(users.username)
SQL
    execute <<SQL
      UPDATE users
      SET users.email = LOWER(users.email)
      WHERE users.email != LOWER(users.email)
SQL
  end

  def self.down
  end
end
