class PostVisibilitiesOnContacts < ActiveRecord::Migration
  def self.move_author_pvs_to_aspect_pvs
    where_clause = <<SQL
      FROM post_visibilities as pv
        INNER JOIN aspects ON aspects.id = pv.aspect_id
        INNER JOIN posts ON posts.id = pv.post_id
          INNER JOIN people ON posts.author_id = people.id
      WHERE people.owner_id = aspects.user_id
SQL

    execute("INSERT into aspect_visibilities SELECT pv.id, pv.post_id, pv.aspect_id, pv.created_at, pv.updated_at #{where_clause}")

    execute("DELETE pv #{where_clause}")
  end

  def self.set_pv_contact_ids
    execute <<SQL
    UPDATE post_visibilities as pv
      INNER JOIN posts ON posts.id = pv.post_id
        INNER JOIN people ON posts.author_id = people.id
      INNER JOIN aspects ON aspects.id = pv.aspect_id
        INNER JOIN users ON users.id = aspects.user_id
          INNER JOIN contacts ON contacts.user_id = users.id
    SET pv.contact_id = contacts.id
    WHERE people.id = contacts.person_id
SQL
  end

  def self.delete_duplicate_pvs
    execute('DELETE FROM post_visibilities WHERE post_visibilities.contact_id = 0')

    duplicate_rows = execute <<SQL
      SELECT COUNT(pv.contact_id), pv.contact_id, pv.post_id from post_visibilities AS pv
        GROUP BY pv.contact_id, pv.post_id
          HAVING COUNT(*)>1;
SQL
    duplicate_rows.each do |row|
      count = row.first
      contact_id = row[1]
      post_id = row.last

      execute <<SQL
        DELETE FROM post_visibilities
        WHERE post_visibilities.contact_id = #{contact_id} AND post_visibilities.post_id = #{post_id}
        LIMIT #{count-1}
SQL
    end
  end

  def self.delete_disconnected_pvs
    execute <<SQL
    DELETE post_visibilities FROM post_visibilities
      LEFT OUTER JOIN posts ON post_visibilities.post_id = posts.id
      LEFT OUTER JOIN aspects ON post_visibilities.aspect_id = aspects.id
    WHERE aspects.id IS NULL OR posts.id IS NULL
SQL
  end

  def self.pv_count
    @pv_count ||= execute('SELECT count(*) FROM post_visibilities').to_a.first.first
  end

  def self.up
    create_table :aspect_visibilities do |t|
      t.integer :post_id, :null => false
      t.integer :aspect_id, :null => false
      t.timestamps
    end
    add_index :aspect_visibilities, [:post_id, :aspect_id], :unique => true
    add_index :aspect_visibilities, [:aspect_id]
    add_index :aspect_visibilities, [:post_id]
    add_foreign_key :aspect_visibilities, :aspects, :dependent => :delete
    add_foreign_key :aspect_visibilities, :posts, :dependent => :delete

    delete_disconnected_pvs if pv_count > 0

    add_column :post_visibilities, :contact_id, :integer, :null => false

    move_author_pvs_to_aspect_pvs if pv_count > 0
    set_pv_contact_ids if pv_count > 0

    delete_duplicate_pvs if pv_count > 0

    remove_index :post_visibilities, [:aspect_id, :post_id]
    remove_column :post_visibilities, :aspect_id

    add_index :post_visibilities, [:contact_id, :post_id], :unique => true
    add_index :post_visibilities, [:contact_id]
    add_foreign_key :post_visibilities, :contacts, :dependent => :delete
    add_foreign_key :post_visibilities, :posts, :dependent => :delete
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
