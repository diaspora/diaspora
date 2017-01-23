class AddScheduledCheckToPod < ActiveRecord::Migration
  def change
    add_column :pods, :scheduled_check, :boolean, default: false, null: false
  end
end
