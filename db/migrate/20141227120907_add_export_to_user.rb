class AddExportToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :export, :string
    add_column :users, :exported_at, :datetime
    add_column :users, :exporting, :boolean, default: false
  end
end
