class CreateDataPoints < ActiveRecord::Migration
  def self.up
    create_table :data_points do |t|
      t.string :key
      t.integer :value
      t.integer :statistic_id

      t.timestamps
    end
    add_index :data_points, :statistic_id
  end

  def self.down
    remove_index :data_points, :statistic_id
    drop_table :data_points
  end
end
