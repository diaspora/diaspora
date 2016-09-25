class AddVideoUrlToOpenGraphCache < ActiveRecord::Migration
  def change
    add_column :open_graph_caches, :video_url, :text
  end
end
