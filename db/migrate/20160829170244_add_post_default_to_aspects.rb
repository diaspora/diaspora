class AddPostDefaultToAspects < ActiveRecord::Migration
  def self.up
    add_column :aspects, :post_default, :boolean, default: true
    add_column :users, :post_default_public, :boolean, default: false
  end
  
  def self.down
    remove_column :aspects, :post_default
    remove_column :users, :post_default_public
  end
end
