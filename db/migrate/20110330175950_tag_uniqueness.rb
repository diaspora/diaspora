class TagUniqueness < ActiveRecord::Migration
  def self.up
    add_index :taggings, [:taggable_id, :taggable_type, :context, :tag_id], :unique => true, :name => 'index_taggings_uniquely'
  end

  def self.down
    remove_index :taggings, :name => 'index_taggings_uniquely'
  end
end
