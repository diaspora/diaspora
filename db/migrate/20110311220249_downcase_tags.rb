class DowncaseTags < ActiveRecord::Migration
  def self.consolidate_tags_with_name(name)
    tags = execute("SELECT * FROM tags WHERE tags.name = '#{name}';").to_a
    keep_tag = tags.pop
    tags.each do |bad_tag|
      execute("UPDATE taggings
        SET taggings.tag_id = #{keep_tag.first}
        WHERE taggings.tag_id = #{bad_tag.first};")
      execute("DELETE FROM tags WHERE tags.id = #{bad_tag.first};")
    end
  end
  def self.up
    execute('UPDATE tags
            SET tags.name = LOWER(tags.name);')

    names_with_duplicates = execute('SELECT name FROM tags
                     GROUP BY name
                     HAVING COUNT(*)>1;').to_a.flatten!
    names_with_duplicates.each do |name|
      consolidate_tags_with_name(name)
    end unless names_with_duplicates.blank?
  end

  def self.down
  end
end
