class UniqueIndexOnProfile < ActiveRecord::Migration
  def self.up
    columns = Profile.column_names
    ["id", "created_at", "updated_at"].each{|n| columns.delete(n)}

    sql = <<-SQL
    SELECT `profiles`.person_id FROM `profiles`
      GROUP BY #{columns.join(',')}
        HAVING COUNT(*)>1 AND `profiles`.person_id IS NOT NULL;
    SQL
    result = Profile.connection.execute(sql)
    duplicate_person_ids = result.to_a.flatten

    undesired_profile_ids = []
    duplicate_person_ids.each do |person_id|
      ids = Profile.where(:person_id => person_id).map!{|p| p.id}
      ids.pop
      undesired_profile_id.concat(ids)
    end
    Profile.where(:id => undesired_profile_ids).delete_all

    remove_index :profiles, :person_id
    add_index    :profiles, :person_id, :unique => true
  end

  def self.down
    remove_index :profiles, :person_id
  end
end
