class ChangeUserIdTypeToInteger < ActiveRecord::Migration
  def up
    change_column :reports, :user_id, :integer
  end

  def down
    change_column :reports, :user_id, :string
  end
end
