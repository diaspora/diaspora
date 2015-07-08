class CreateScope < ActiveRecord::Migration
  def change
    create_table :scopes do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
