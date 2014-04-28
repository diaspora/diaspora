class AddPostTypeToPostReport < ActiveRecord::Migration
  def change
    add_column :post_reports, :post_type, :string, :null => false, :after => :post_id, :default => 'post'
    change_column_default :post_reports, :post_type, nil
  end
end
