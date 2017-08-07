class AddVideoUrlToOpenGraphCache < ActiveRecord::Migration[4.2]
  def change
    add_column :open_graph_caches, :video_url, :text
  end
end
