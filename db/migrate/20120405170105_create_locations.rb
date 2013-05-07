class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :address
      t.string :lat
      t.string :lng
      t.integer :status_message_id

      t.timestamps
    end
  end
end
