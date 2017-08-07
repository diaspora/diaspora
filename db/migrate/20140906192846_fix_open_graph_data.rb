class FixOpenGraphData < ActiveRecord::Migration[4.2]
  def self.up
    change_column :open_graph_caches, :url, :text
    change_column :open_graph_caches, :image, :text
  end
  def self.down
    change_column :open_graph_caches, :url, :string
    change_column :open_graph_caches, :image, :string
  end
end
