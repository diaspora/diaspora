class AddOpenGraphCache < ActiveRecord::Migration
  def up
    create_table :open_graph_caches do |t|
      t.string :title
      t.string :ob_type
      t.string :image
      t.string :url
      t.text :description
    end
    change_table :posts do |t|
      t.integer :open_graph_cache_id
    end
  end

  def down
    remove_column :posts, :open_graph_cache_id
    drop_table :open_graph_caches
  end
end
