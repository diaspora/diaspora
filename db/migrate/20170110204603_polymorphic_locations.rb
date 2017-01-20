class PolymorphicLocations < ActiveRecord::Migration
  def up
    rename_column :locations, :status_message_id, :localizable_id
    change_column_null :locations, :localizable_id, false
    add_column :locations, :localizable_type, :string, limit: 60, null: true
    Location.update_all(localizable_type: "Post")
    change_column_null :locations, :localizable_type, false
    add_index :locations, %i{localizable_id localizable_type}, unique: true
  end

  def down
    Location.where.not(localizable_type: "Post").destroy_all
    remove_index :locations, %i{localizable_id localizable_type}
    rename_column :locations, :localizable_id, :status_message_id
    change_column_null :locations, :status_message_id, true
    remove_column :locations, :localizable_type
  end
end
