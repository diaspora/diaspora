class CreateParticipations < ActiveRecord::Migration
  def self.up
    create_table "participations", :force => true do |t|
      t.string   "guid"
      t.integer  "target_id"
      t.string   "target_type",             :limit => 60,                   :null => false
      t.integer  "author_id"
      t.text     "author_signature"
      t.text     "parent_author_signature"
      t.timestamps
    end
  end

  def self.down
    drop_table :participations
  end
end
