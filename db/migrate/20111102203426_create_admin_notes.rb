class CreateAdminNotes < ActiveRecord::Migration
  def self.up
    create_table :admin_notes do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :admin_user, :polymorphic => true
      t.text :body
      t.timestamps
    end
    add_index :admin_notes, [:resource_type, :resource_id]
    add_index :admin_notes, [:admin_user_type, :admin_user_id]
  end

  def self.down
    drop_table :admin_notes
  end
end
