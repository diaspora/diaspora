class UniqueIndexPostVisibilities < ActiveRecord::Migration
  def self.up
    visibility_ids = execute('select id from post_visibilities').to_a
    unless visibility_ids.empty?
      sql = <<-SQL
      SELECT `post_visibilities`.post_id, `post_visibilities`.aspect_id FROM `post_visibilities`
        GROUP BY post_id, aspect_id
          HAVING COUNT(*)>1;
      SQL

      result = execute(sql)
      dup_pvs = result.to_a
      undesired_ids = []

      dup_pvs.each do |arr|
        post_id, aspect_id = arr
        pv_ids = execute("
          SELECT `post_visibilities`.id FROM `post_visibilities`
          WHERE `post_visibilities`.post_id = #{post_id}
            AND `post_visibilities`.aspect_id = #{aspect_id};"
        ).to_a.flatten!
        pv_ids.pop
        undesired_ids.concat(pv_ids)
      end
      execute("DELETE FROM `post_visibilities` WHERE `post_visibilities`.id IN (#{undesired_ids.join(",")});") unless undesired_ids.empty?

      new_result = execute(sql)
      raise "Not all violating visibilities deleted, try migrating again if this is the first occurence" unless new_result.to_a.empty?
    end

    remove_index :post_visibilities, [:aspect_id, :post_id]
    add_index :post_visibilities, [:aspect_id, :post_id], :unique => true
  end

  def self.down
    remove_index :post_visibilities, [:aspect_id, :post_id]
    add_index :post_visibilities, [:aspect_id, :post_id]
  end
end
