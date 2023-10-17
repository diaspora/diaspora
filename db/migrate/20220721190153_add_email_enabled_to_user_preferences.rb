# frozen_string_literal: true

class AddEmailEnabledToUserPreferences < ActiveRecord::Migration[6.1]
  def change
    change_table :user_preferences, bulk: true do |t|
      t.boolean :email_enabled, null: false, default: false
      t.boolean :in_app_enabled, null: false, default: true
    end
  end
end
