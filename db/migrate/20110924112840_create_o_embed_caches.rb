class CreateOEmbedCaches < ActiveRecord::Migration
  def self.up
    create_table :o_embed_caches do |t|
      t.string :url, :limit => 1024, :null => false, :unique => true
      t.text :data, :null => false
    end
    add_index :o_embed_caches, :url
  end

  def self.down
    remove_index :o_embed_caches, :column => :url
    drop_table :o_embed_caches
  end
end
