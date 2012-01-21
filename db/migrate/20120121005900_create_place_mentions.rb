class CreatePlaceMentions < ActiveRecord::Migration
  def self.up
    create_table :place_mentions do |t|
      t.integer :post_id
      t.integer :place_id

      t.timestamps
    end
  end

  def self.down
    drop_table :place_mentions
  end
end
