class UniqueIndexOnProfile < ActiveRecord::Migration
  def self.up
    conn = ActiveRecord::Base.connection
    columns = conn.columns("profiles").map{|c| c.name}
    ["id", "created_at", "updated_at"].each{|n| columns.delete(n)}

    sql = <<-SQL
    SELECT profiles.person_id FROM profiles
      GROUP BY #{columns.join(',')}
        HAVING COUNT(*)>1 AND profiles.person_id IS NOT NULL;
    SQL
    result = conn.execute(sql)
    duplicate_person_ids = result.to_a.flatten

    undesired_profile_ids = []
    duplicate_person_ids.each do |person_id|
      profile_ids = conn.execute("
        SELECT profiles.id FROM profiles
        WHERE profiles.person_id = #{person_id};").to_a.flatten
      profile_ids.pop
      undesired_profile_ids.concat(profile_ids)
    end
    conn.execute("DELETE FROM profiles
      WHERE profiles.id IN (#{undesired_profile_ids.join(",")});") unless undesired_profile_ids.empty?

    remove_index :profiles, :person_id
    add_index    :profiles, :person_id, :unique => true
  end

  def self.down
    remove_index :profiles, :person_id
  end
end
