class AddHiddenIndicies < ActiveRecord::Migration
  def self.up
    remove_index :post_visibilities, :hidden
    add_index :post_visibilities, [:post_id, :hidden, :contact_id], :unique => true
  end


  def self.down
    remove_index :post_visibilities, :column => [:post_id, :hidden, :contact_id]
    add_index :post_visibilities, :hidden
  end
end
