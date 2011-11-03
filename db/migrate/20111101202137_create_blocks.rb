class CreateBlocks < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.integer :user_id
      t.integer :person_id
    end
  end

  def self.down
    drop_table :blocks
  end
end
