class AddContactsVisible < ActiveRecord::Migration
  def self.up
    add_column :aspects, :contacts_visible, :boolean, :default => true, :null => false
    add_index :aspects, [:user_id, :contacts_visible]

    ActiveRecord::Base.connection.execute <<-SQL
    UPDATE aspects
      SET contacts_visible = false
      WHERE contacts_visible IS NULL
    SQL
  end

  def self.down
    remove_index :aspects, [:user_id, :contacts_visible]
    remove_column :aspects, :contacts_visible
  end
end
