class AddStatusToPods < ActiveRecord::Migration
  def change
    add_column :pods, :status, :integer, default: 0
    add_column :pods, :checked_at, :datetime, default: Time.zone.at(0)
    add_column :pods, :offline_since, :datetime, default: nil
    add_column :pods, :response_time, :integer, default: -1
    add_column :pods, :software, :string, limit: 255
    add_column :pods, :error, :string, limit: 255

    add_index :pods, :status
    add_index :pods, :checked_at
    add_index :pods, :offline_since
  end
end
