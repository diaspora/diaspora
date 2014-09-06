class FixOpenGraphData < ActiveRecord::Migration
  def self.up
    change_column :open_graph_caches, :url, :text
    change_column :open_graph_caches, :image, :text
  end
  def self.down
    change_column :open_graph_caches, :url, :string
    change_column :open_graph_caches, :image, :string
  end
end
