class RenamePostColumnsToItem < ActiveRecord::Migration
  def up
    rename_column :reports, :post_id, :item_id
    rename_column :reports, :post_type, :item_type
  end

  def down
    rename_column :reports, :item_id, :post_id
    rename_column :reports, :item_type, :post_type
  end
end
