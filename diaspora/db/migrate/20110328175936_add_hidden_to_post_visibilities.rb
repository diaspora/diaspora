class AddHiddenToPostVisibilities < ActiveRecord::Migration
  def self.up
    add_column :post_visibilities, :hidden, :boolean, :default => false, :null => false
    add_index :post_visibilities, :hidden
  end

  def self.down
    remove_index :post_visibilities, :hidden
    remove_column :post_visibilities, :hidden
  end
end
