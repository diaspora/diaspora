class AddPostTypeToPostReport < ActiveRecord::Migration
  def change
    add_column :post_reports, :post_type, :string, :null => false, :after => :post_id
  end
end
