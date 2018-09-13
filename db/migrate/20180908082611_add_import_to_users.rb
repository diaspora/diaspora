class AddImportToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :import, :string
  end
end
