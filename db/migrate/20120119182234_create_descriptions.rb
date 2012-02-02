class CreateDescriptions < ActiveRecord::Migration
  def self.up
    create_table :descriptions do |t|
      t.string   "diaspora_handle"
      t.string   "image_url"
      t.string   "image_url_small"
      t.string   "image_url_medium"
      t.boolean  "searchable",                      :default => true, :null => false
      t.integer  "place_id",                                         :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "location"
      t.string   "title",        :limit => 70
      t.text :summary
      t.decimal :lat
      t.decimal :lng
      t.timestamps
    end
  end

  def self.down
    drop_table :descriptions
  end
end
