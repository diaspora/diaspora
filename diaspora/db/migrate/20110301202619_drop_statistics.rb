class DropStatistics < ActiveRecord::Migration
  def self.up
    drop_table :statistics
    drop_table :data_points
  end

  def self.down
  end
end
