class GuidIsUnique < ActiveRecord::Migration
  def self.consolidate_post(guid)
    post_ids = execute("select posts.id from posts where posts.guid = '#{guid}'").to_a.flatten!
    keep_id = post_ids.pop
    execute("UPDATE comments
            SET comments.post_id = #{keep_id}
            WHERE comments.post_id IN (#{post_ids.join(',')})")

    execute("UPDATE posts
            SET posts.status_message_id = #{keep_id}
            WHERE posts.status_message_id IN (#{post_ids.join(',')})")

    execute("DELETE FROM post_visibilities WHERE post_visibilities.post_id IN (#{post_ids.join(',')})")
    execute("DELETE FROM mentions WHERE mentions.post_id IN (#{post_ids.join(',')})")
    execute("DELETE FROM posts WHERE posts.id IN (#{post_ids.join(',')})")
  end
  def self.up
    sql = <<-SQL
    SELECT posts.guid FROM posts
      GROUP BY posts.guid
        HAVING COUNT(*)>1;
    SQL
    duplicated_guids = execute(sql).to_a.flatten!

    duplicated_guids.each do |guid|
      consolidate_post(guid)
    end if duplicated_guids
    remove_index :posts, :guid
    add_index :posts, :guid, :unique => true
  end

  def self.down
    remove_index :posts, :column => :guid
    add_index :posts, :guid
  end
end
