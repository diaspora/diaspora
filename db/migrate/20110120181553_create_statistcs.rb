class CreateStatistcs < ActiveRecord::Migration
  def self.up
    create_table :statistcs do |t|
      t.integer :average
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :statistcs
  end
end
