# frozen_string_literal: true

class ChangeNotificationsGuidNotNull < ActiveRecord::Migration[5.2]
  def up
    Notification.where(guid: nil).find_in_batches do |batch|
      batch.each do |notification|
        notification.save!(validate: false, touch: false)
      end
    end

    change_column :notifications, :guid, :string, null: false
  end

  def down
    change_column :notifications, :guid, :string, null: true
  end
end
