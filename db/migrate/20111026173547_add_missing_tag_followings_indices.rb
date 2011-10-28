class AddMissingTagFollowingsIndices < ActiveRecord::Migration
  def self.delete_duplicate_tag_followings
    duplicate_rows = execute <<SQL
      SELECT COUNT(tf.user_id), tf.user_id, tf.tag_id from tag_followings AS tf
        GROUP BY tf.user_id, tf.tag_id
          HAVING COUNT(*)>1;
SQL
    duplicate_rows.each do |row|
      count = row.first
      user_id = row[1]
      tag_id = row.last

      execute <<SQL
        DELETE FROM tag_followings
        WHERE tag_followings.user_id = #{user_id} AND tag_followings.tag_id = #{tag_id}
        LIMIT #{count-1}
SQL
    end
  end

  def self.up
    delete_duplicate_tag_followings

    add_index :tag_followings, :tag_id
    add_index :tag_followings, :user_id
    add_index :tag_followings, [:tag_id, :user_id], :unique => true
  end

  def self.down
    remove_index :tag_followings, :column => [:tag_id, :user_id]
    remove_index :tag_followings, :column => :user_id
    remove_index :tag_followings, :column => :tag_id
  end
end
