class UpdateDevise < ActiveRecord::Migration
  def up
    remove_column :users, :remember_token
    add_column :users, :reset_password_sent_at, :datetime
  end

  def down
    add_column :users, :remember_token, :string
    remove_column :users, :reset_password_sent_at
  end
end
