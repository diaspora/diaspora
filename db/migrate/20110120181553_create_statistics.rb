class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.integer :average
      t.string :type
      t.datetime :time

      t.timestamps
    end
  end

  def self.down
    drop_table :statistcs
  end
end
