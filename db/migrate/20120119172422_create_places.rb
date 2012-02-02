class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string   "guid",                                     :null => false
      t.text     "url",                                      :null => false
      t.string   "diaspora_handle",                          :null => false
      t.text     "serialized_public_key",                    :null => false
      t.integer  "owner_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "closed_account",        :default => false
    end
  end

  def self.down
    drop_table :places
  end
end
