class CreateMentions < ActiveRecord::Migration
  def self.up
    create_table :mentions do |t|
      t.integer :post_id, :null => false
      t.integer :person_id, :null => false
    end
    add_index :mentions, :post_id
    add_index :mentions, :person_id
    add_index :mentions, [:person_id, :post_id], :unique => true
  end

  def self.down
    drop_table :mentions
  end
end
