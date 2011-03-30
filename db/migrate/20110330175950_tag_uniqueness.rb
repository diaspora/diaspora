class TagUniqueness < ActiveRecord::Migration
  def self.delete_duplicate_taggings
    duplicate_rows = execute <<SQL
      SELECT COUNT(t.taggable_id), t.taggable_id, t.taggable_type, t.tag_id FROM taggings AS t
        GROUP BY t.taggable_id, t.taggable_type, t.tag_id
          HAVING COUNT(*)>1;
SQL
    duplicate_rows.each do |row|
      execute <<SQL
        DELETE FROM taggings
        WHERE taggings.taggable_id = #{row[1]} AND taggings.taggable_type = '#{row[2]}' AND taggings.tag_id = #{row[3]}
        LIMIT #{row[0]-1}
SQL
    end
  end
  def self.up
    delete_duplicate_taggings
    add_index :taggings, [:taggable_id, :taggable_type, :tag_id], :unique => true, :name => 'index_taggings_uniquely'
  end

  def self.down
    remove_index :taggings, :name => 'index_taggings_uniquely'
  end
end
