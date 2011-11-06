class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.float :longitude
      t.float :latitude
      t.string :address

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
