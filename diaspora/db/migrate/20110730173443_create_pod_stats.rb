class CreatePodStats < ActiveRecord::Migration
  def self.up
    create_table :pod_stats do |t|
      t.integer :error_code
      t.integer :person_id
      t.text :error_message
      t.integer :pod_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pod_stats
  end
end
