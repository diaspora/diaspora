class TagNameUniqueness < ActiveRecord::Migration
  class Tag < ActiveRecord::Base; end

  def self.downcase_tags
    execute <<SQL
      UPDATE tags
      SET tags.name = LOWER(tags.name)
      WHERE tags.name != LOWER(tags.name)
SQL
  end
  def self.consolidate_duplicate_tags
    duplicate_rows = execute <<SQL
    SELECT count(tags.name), tags.name FROM tags
      GROUP BY tags.name
        HAVING COUNT(*) > 1
SQL
    duplicate_rows.each do |row|
      name = row.last
      tag_ids = execute("SELECT tags.id FROM tags WHERE tags.name = '#{name}'").to_a.flatten!
      id_to_keep = tag_ids.pop
      execute <<SQL
              UPDATE IGNORE taggings
                SET taggings.tag_id = #{id_to_keep}
                WHERE taggings.tag_id IN (#{tag_ids.join(',')})
SQL
      execute <<SQL
        DELETE FROM taggings WHERE taggings.tag_id IN (#{tag_ids.join(',')})
SQL

      execute("DELETE FROM tags WHERE tags.id IN (#{tag_ids.join(',')})")
    end
  end

  def self.up
    if Tag.count > 0
      downcase_tags
      consolidate_duplicate_tags
    end
    add_index :tags, :name, :unique => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
