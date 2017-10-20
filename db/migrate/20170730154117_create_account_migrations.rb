# frozen_string_literal: true

class CreateAccountMigrations < ActiveRecord::Migration[5.1]
  def change
    create_table :account_migrations do |t|
      t.integer :old_person_id, null: false
      t.integer :new_person_id, null: false
    end

    add_foreign_key :account_migrations, :people, column: :old_person_id
    add_foreign_key :account_migrations, :people, column: :new_person_id

    add_index :account_migrations, %i[old_person_id new_person_id], unique: true
    add_index :account_migrations, :old_person_id, unique: true
  end
end
