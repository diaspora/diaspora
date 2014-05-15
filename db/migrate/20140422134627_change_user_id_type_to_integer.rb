class ChangeUserIdTypeToInteger < ActiveRecord::Migration
  def up
    remove_column :reports, :user_id
    add_column :reports, :user_id, :integer, :null => false, :default => 1
    change_column_default :reports, :user_id, nil
  end

  def down
    remove_column :reports, :user_id
    add_column :reports, :user_id, :string
  end
end
