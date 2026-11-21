# frozen_string_literal: true

class RenameUserPreferencesToNotificationSettings < ActiveRecord::Migration[6.1]
  def change
    rename_table :user_preferences, :notification_settings
    rename_column :notification_settings, :email_type, :type
    change_table :notification_settings, bulk: true do |t|
      t.boolean :email_enabled, null: false, default: false
      t.boolean :in_app_enabled, null: false, default: true
    end
  end
end
