class UniqueIndexPostVisibilities < ActiveRecord::Migration
  def self.up
    remove_index :post_visibilities, [:aspect_id, :post_id]
    add_index :post_visibilities, [:aspect_id, :post_id], :unique => true
  end

  def self.down
    remove_index :post_visibilities, [:aspect_id, :post_id]
    add_index :post_visibilities, [:aspect_id, :post_id]
  end
end
