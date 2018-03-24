# frozen_string_literal: true

class AddScheduledCheckToPod < ActiveRecord::Migration[4.2]
  def change
    add_column :pods, :scheduled_check, :boolean, default: false, null: false
  end
end
