class AddHiddenToPostVisibilities < ActiveRecord::Migration
  def self.up
    add_column :post_visibilities, :hidden, :boolean, :defalut => false, :null => false
  end

  def self.down
    remove_column :post_visibilities, :hidden
  end
end
