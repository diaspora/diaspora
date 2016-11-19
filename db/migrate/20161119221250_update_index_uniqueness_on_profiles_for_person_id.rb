class UpdateIndexUniquenessOnProfilesForPersonId < ActiveRecord::Migration
  def up
    remove_foreign_key :profiles, name: "profiles_person_id_fk"
    remove_index :profiles, :person_id
    add_index :profiles, :person_id, unique: true
    add_foreign_key :profiles, :people, name: "profiles_person_id_fk", on_delete: :cascade
  end

  def down
    remove_foreign_key :profiles, name: "profiles_person_id_fk"
    remove_index :profiles, :person_id
    add_index :profiles, :person_id
    add_foreign_key :profiles, :people, name: "profiles_person_id_fk", on_delete: :cascade
  end
end
