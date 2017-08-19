class CleanupDuplicatesAndAddUniqueIndexes < ActiveRecord::Migration[4.2]
  def up
    # temporary index to speed up the migration
    add_index :photos, :guid, length: 191

    # fix share visibilities for private photos
    if AppConfig.postgres?
      execute "UPDATE share_visibilities" \
              " SET shareable_id = (SELECT MIN(p3.id) FROM photos as p3 WHERE p3.guid = p1.guid)" \
              " FROM photos as p1, photos as p2" \
              " WHERE p1.id = share_visibilities.shareable_id AND (p1.guid = p2.guid AND p1.id > p2.id)" \
              " AND share_visibilities.shareable_type = 'Photo'"
    else
      execute "UPDATE share_visibilities" \
              " INNER JOIN photos as p1 ON p1.id = share_visibilities.shareable_id" \
              " INNER JOIN photos as p2 ON p1.guid = p2.guid AND p1.id > p2.id" \
              " SET share_visibilities.shareable_id = (SELECT MIN(p3.id) FROM photos as p3 WHERE p3.guid = p1.guid)" \
              " WHERE share_visibilities.shareable_type = 'Photo'"
    end

    %i(conversations messages photos polls poll_answers poll_participations).each do |table|
      delete_duplicates_and_create_unique_index(table)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def delete_duplicates_and_create_unique_index(table)
    # temporary index to speed up the migration
    add_index table, :guid, length: 191 unless table == :photos

    if AppConfig.postgres?
      execute "DELETE FROM #{table} AS t1 USING #{table} AS t2 WHERE t1.guid = t2.guid AND t1.id > t2.id"
    else
      execute "DELETE t1 FROM #{table} t1, #{table} t2 WHERE t1.guid = t2.guid AND t1.id > t2.id"
    end

    remove_index table, column: :guid

    # now create unique index \o/
    add_index table, :guid, length: 191, unique: true
  end
end
