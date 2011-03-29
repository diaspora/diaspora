class PostVisibilitiesOnContacts < ActiveRecord::Migration
  def self.move_author_pvs_to_aspect_pvs
    where_clause = <<SQL
      FROM post_visibilities as pv 
        INNER JOIN aspects ON aspects.id = pv.aspect_id
        INNER JOIN posts ON posts.id = pv.post_id
          INNER JOIN people ON posts.author_id = people.id
      WHERE people.owner_id = aspects.user_id
SQL

    ids = execute("SELECT pv.id #{where_clause}").to_a

    unless ids.blank?
      execute("INSERT into aspect_visibilities SELECT pv.post_id, pv.aspect_id #{where_clause}")

      execute <<SQL
      DELETE FROM post_visibilities
      WHERE post_visibilities.id IN (#{ids.join(',')})
SQL
    end
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

  def self.up
    create_table :aspect_visibilities do |t|
      t.integer :post_id, :null => false
      t.integer :aspect_id, :null => false
    end
    add_index :aspect_visibilities, [:post_id, :aspect_id], :unique => true
    add_foreign_key :aspect_visibilities, :aspects, :dependent => :delete
    add_foreign_key :aspect_visibilities, :posts, :dependent => :delete

    add_column :post_visibilities, :contact_id, :integer, :null => false
    add_index :post_visibilities, [:contact_id, :post_id], :unique => true

    move_author_pvs_to_aspect_pvs
    set_pv_contact_ids

    remove_index :post_visibilities, [:aspect_id, :post_id]
    remove_column :post_visibilities, :aspect_id
    add_foreign_key :post_visibilities, :contacts, :dependent => :delete
    add_foreign_key :post_visibilities, :posts, :dependent => :delete
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
