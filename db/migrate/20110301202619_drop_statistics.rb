class DropStatistics < ActiveRecord::Migration
  def self.up
    execute 'DROP TABLE statistics'
    execute 'DROP TABLE data_points'
  end

  def self.down
  end
end
