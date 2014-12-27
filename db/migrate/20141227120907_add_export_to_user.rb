class AddExportToUser < ActiveRecord::Migration
  def change
    add_column :users, :export, :string
    add_column :users, :exported_at, :datetime
    add_column :users, :exporting, :boolean, default: false
  end
end
