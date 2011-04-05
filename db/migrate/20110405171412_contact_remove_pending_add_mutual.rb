class ContactRemovePendingAddMutual < ActiveRecord::Migration
  def self.up
    add_column :contacts, :mutual, :boolean, :default => false, :null => false

    execute( <<SQL
      UPDATE contacts
        SET contacts.mutual = true
          WHERE contacts.pending = false
SQL
)

    remove_foreign_key "contacts", "people"
    remove_index :contacts, [:person_id, :pending]
    remove_index :contacts, [:user_id, :pending]

    add_index :contacts, :person_id
    add_foreign_key "contacts", "people", :name => "contacts_person_id_fk", :dependent => :delete

    remove_column :contacts, :pending
  end

  def self.down

    remove_foreign_key "contacts", "people"
    remove_index :contacts, :person_id

    add_column :contacts, :pending, :default => true, :null => false
    add_index :contacts, [:user_id, :pending]

    add_index :contacts, [:person_id, :pending]
    add_foreign_key "contacts", "people", :name => "contacts_person_id_fk", :dependent => :delete

    execute( <<SQL
      UPDATE contacts
        SET contacts.pending = false
          WHERE contacts.mutual = true
SQL
)

    remove_column :contacts, :mutual
  end
end
