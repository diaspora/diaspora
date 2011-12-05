class CreateCheckIns < ActiveRecord::Migration
  def self.up
    create_table :check_ins do |t|
      t.integer :location_id
      t.integer :post_id

      t.timestamps
    end
  end

  def self.down
    drop_table :check_ins
  end
end
