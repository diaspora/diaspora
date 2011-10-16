class ShareAnything < ActiveRecord::Migration
  def self.up
    remove_foreign_key :aspect_visibilities, :posts
    remove_index :aspect_visibilities, :post_id_and_aspect_id
    remove_index :aspect_visibilities, :post_id

    change_table :aspect_visibilities do |t|
      t.rename :post_id, :shareable_id
      t.string :shareable_type, :default => 'Post', :null => false
    end

    add_index :aspect_visibilities, [:shareable_id, :shareable_type, :aspect_id], :name => 'shareable_and_aspect_id'
    add_index :aspect_visibilities, [:shareable_id, :shareable_type]


    remove_foreign_key :post_visibilities, :posts
    remove_index :post_visibilities, :contact_id_and_post_id
    remove_index :post_visibilities, :post_id_and_hidden_and_contact_id

    change_table :post_visibilities do |t|
      t.rename :post_id, :shareable_id
      t.string :shareable_type, :default => 'Post', :null => false
    end

    rename_table :post_visibilities, :share_visibilities
    add_index :share_visibilities, [:shareable_id, :shareable_type, :contact_id], :name => 'shareable_and_contact_id'
    add_index :share_visibilities, [:shareable_id, :shareable_type, :hidden, :contact_id], :name => 'shareable_and_hidden_and_contact_id'
  end


  def self.down
    remove_index :share_visibilities, :name => 'shareable_and_hidden_and_contact_id'
    remove_index :share_visibilities, :name => 'shareable_and_contact_id'
    rename_table :share_visibilities, :post_visibilities 

    change_table :post_visibilities do |t|
      t.remove :shareable_type
      t.rename :shareable_id, :post_id
    end

    add_index :post_visibilities, [:post_id, :hidden, :contact_id]
    add_index :post_visibilities, [:contact_id, :post_id]
    add_foreign_key :post_visibilities, :posts


    remove_index :aspect_visibilities, [:shareable_id, :shareable_type]
    remove_index :aspect_visibilities, :name => 'shareable_and_aspect_id'

    change_table :aspect_visibilities do |t|
      t.remove :shareable_type
      t.rename :shareable_id, :post_id
    end

    add_index :aspect_visibilities, :post_id
    add_index :aspect_visibilities, [:post_id, :aspect_id]
    add_foreign_key :aspect_visibilities, :posts
  end
end
