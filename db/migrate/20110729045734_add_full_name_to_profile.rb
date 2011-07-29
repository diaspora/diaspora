class AddFullNameToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :full_name, :string, :limit => 70

    add_index :profiles, :full_name
    add_index :profiles, [:full_name, :searchable]
    remove_index :profiles, [:first_name, :last_name, :searchable]
    remove_index :profiles, [:first_name, :searchable]
    remove_index :profiles, [:last_name, :searchable]

    execute("UPDATE profiles SET full_name=LOWER(CONCAT(first_name, ' ', last_name))")
  end

  def self.down
    remove_index :profiles, :column => :full_name
    remove_column :profiles, :full_name

    add_index :profiles, [:first_name, :searchable]
    add_index :profiles, [:last_name, :searchable]
    add_index :profiles, [:first_name, :last_name, :searchable]
  end
end
