# frozen_string_literal: true

class AddImportingDataFieldToUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.column :importing, :boolean, default: false, null: false
      t.column :importing_photos, :boolean, default: false, null: false
    end
  end
end
