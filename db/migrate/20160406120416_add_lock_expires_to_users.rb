class AddLockExpiresToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lock_expires, :boolean, default: false
  end
end
