class ShareAnything < ActiveRecord::Migration
  def self.up
    remove_foreign_key :aspect_visibilities, :posts
    remove_index :aspect_visibilities, :post_id_and_aspect_id
    remove_index :aspect_visibilities, :post_id

    change_table :aspect_visibilities do |t|
      t.rename :post_id, :shareable_id
      t.string :shareable_type, :default => 'Post', :null => false
    end


    remove_foreign_key :post_visibilities, :posts
    remove_index :post_visibilities, :contact_id_and_post_id
    remove_index :post_visibilities, :post_id_and_hidden_and_contact_id

    change_table :post_visibilities do |t|
      t.rename :post_id, :shareable_id
      t.string :shareable_type, :default => 'Post', :null => false
    end
    rename_table :post_visibilities, :share_visibilities 
  end



  def self.down
    rename_column :aspect_visibilities, :shareable_id, :post_id
    add_foreign_key :aspect_visibilities, :posts
    add_index :aspect_visibilities, :post_id
    remove_column :aspect_visibilities, :shareable_type

    rename_table :share_visibilities, :post_visibilities 
    rename_column :post_visibilities, :shareable_id, :post_id
    add_foreign_key :post_visibilities, :posts
    add_index :post_visibilities, :post_id_and_post_id
    add_index :post_visibilities, [:contact_id, :post_id]
    add_index :post_visibilities, [:post_id, :hidden, :contact_id]
    add_index :post_visibilities, :post_id
    remove_column :post_visibilities, :shareable_type
  end
end
