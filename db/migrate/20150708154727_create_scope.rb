class CreateScope < ActiveRecord::Migration
  def change
    create_table :scopes do |t|
      t.primary_key :name, :string

      t.timestamps null: false
    end
  end
end
