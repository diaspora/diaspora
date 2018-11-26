# frozen_string_literal: true

class AddGuidToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :guid, :string
    add_index :notifications, :guid, name: :index_notifications_on_guid, length: 191, unique: true
  end
end
