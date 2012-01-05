class RemovePodStatsTable < ActiveRecord::Migration
  def self.up
    execute 'DROP TABLE pod_stats'
  end

  def self.down
    create_table :pod_stats do |t|
      t.integer :error_code
      t.integer :person_id
      t.text :error_message
      t.integer :pod_id

      t.timestamps
    end
  end
end
