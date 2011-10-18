class ShareAnything < ActiveRecord::Migration
  def self.up
    # add_column :comments, :name, :string
    # add_column :comments, :user_id, :integer, :null => false
    # add_index :comments, :user_id
    # becomes
    # execute "ALTER TABLE comments add name varchar(255), add user_id int NOT NULL, add index `index_comments_on_user_id` (`user_id`);"
    start_sql = "ALTER TABLE aspect_visibilities " 
    sql = []

    #remove_index :aspect_visibilities, :post_id_and_aspect_id
    sql << "remove index `index_post_id_and_aspect_id`"
    
    #remove_index :aspect_visibilities, :post_id
    sql << "remove index `index_aspect_visibilities_on_post_id`"

    # change_table :aspect_visibilities do |t|
    #   t.rename :post_id, :shareable_id
    #   t.string :shareable_type, :default => 'Post', :null => false
    # end

    sql << "RENAME COLUMN post_id shareable_id"
    sql << "ADD shareable_type varchar(255) NOT NULL DEFAULT `Post`"

    # add_index :aspect_visibilities, [:shareable_id, :shareable_type, :aspect_id], :name => 'shareable_and_aspect_id'
    # add_index :aspect_visibilities, [:shareable_id, :shareable_type]
    
    sql << "add index `shareable_and_aspect_id` (`shareable_id`, `shareable_type`, `aspect_id`)"
    sql << "add index `index_aspect_visibilities_on_shareable_id_and_shareable_type` (`shareable_id`, `shareable_type`)"

    execute(start_sql + sql.join(', ') + ';')
    
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

    add_index :post_visibilities, [:post_id, :hidden, :contact_id], :unique => true
    add_index :post_visibilities, [:contact_id, :post_id], :unique => true
    add_foreign_key :post_visibilities, :posts, :dependent => :delete


    remove_index :aspect_visibilities, [:shareable_id, :shareable_type]
    remove_index :aspect_visibilities, :name => 'shareable_and_aspect_id'

    change_table :aspect_visibilities do |t|
      t.remove :shareable_type
      t.rename :shareable_id, :post_id
    end

    add_index :aspect_visibilities, :post_id
    add_index :aspect_visibilities, [:post_id, :aspect_id], :unique => true
    add_foreign_key :aspect_visibilities, :posts, :dependent => :delete

  end
end
