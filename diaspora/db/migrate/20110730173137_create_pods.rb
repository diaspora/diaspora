class CreatePods < ActiveRecord::Migration
  def self.up
    create_table :pods do |t|
      t.string :host
      t.boolean :ssl

      t.timestamps
    end
  end

  def self.down
    drop_table :pods
  end
end
