class ShareAnything < ActiveRecord::Migration
  def self.up
    remove_foreign_key :aspect_visibilities, :posts

    if AppConfig.postgres?
      execute "DROP INDEX index_aspect_visibilities_on_post_id_and_aspect_id"
      execute "DROP INDEX index_aspect_visibilities_on_post_id"
      execute "ALTER TABLE aspect_visibilities RENAME COLUMN post_id TO shareable_id"
      execute "ALTER TABLE aspect_visibilities ADD COLUMN shareable_type VARCHAR(255) NOT NULL DEFAULT 'Post'"
      execute "CREATE INDEX shareable_and_aspect_id ON aspect_visibilities ( shareable_id, shareable_type, aspect_id )"
      execute "CREATE INDEX index_aspect_visibilities_on_shareable_id_and_shareable_type ON aspect_visibilities ( shareable_id, shareable_type )"
    else
      start_sql = "ALTER TABLE aspect_visibilities "
      sql = []

      #remove_index :aspect_visibilities, :post_id_and_aspect_id
      sql << "DROP INDEX `index_aspect_visibilities_on_post_id_and_aspect_id`"

      #remove_index :aspect_visibilities, :post_id
      sql << "DROP INDEX `index_aspect_visibilities_on_post_id`"



      # change_table :aspect_visibilities do |t|

      #   t.rename :post_id, :shareable_id
      #   t.string :shareable_type, :default => 'Post', :null => false
      # end

      sql << "CHANGE COLUMN post_id shareable_id int NOT NULL"
      sql << "ADD shareable_type varchar(255) NOT NULL DEFAULT 'Post'"


      # add_index :aspect_visibilities, [:shareable_id, :shareable_type, :aspect_id], :name => 'shareable_and_aspect_id'
      # add_index :aspect_visibilities, [:shareable_id, :shareable_type]

      sql << "add index `shareable_and_aspect_id` (`shareable_id`, `shareable_type`, `aspect_id`)"
      sql << "add index `index_aspect_visibilities_on_shareable_id_and_shareable_type` (`shareable_id`, `shareable_type`)"


      execute(start_sql + sql.join(', ') + ';')
    end



    remove_foreign_key :post_visibilities, :posts
    rename_table :post_visibilities, :share_visibilities

    if AppConfig.postgres?
      execute "DROP INDEX index_post_visibilities_on_contact_id_and_post_id"
      execute "DROP INDEX index_post_visibilities_on_post_id_and_hidden_and_contact_id"
      execute "ALTER TABLE share_visibilities RENAME COLUMN post_id TO shareable_id"
      execute "ALTER TABLE share_visibilities ADD COLUMN shareable_type VARCHAR(60) NOT NULL DEFAULT 'Post'"
      execute "CREATE INDEX shareable_and_contact_id ON share_visibilities ( shareable_id, shareable_type, contact_id )"
      execute "CREATE INDEX shareable_and_hidden_and_contact_id ON share_visibilities ( shareable_id, shareable_type, hidden, contact_id )"
    else
      start_sql = "ALTER TABLE share_visibilities "
      sql = []

      #remove_index :post_visibilities, :contact_id_and_post_id
      #remove_index :post_visibilities, :post_id_and_hidden_and_contact_id

      sql << "DROP INDEX `index_post_visibilities_on_contact_id_and_post_id`"
      sql << "DROP INDEX `index_post_visibilities_on_post_id_and_hidden_and_contact_id`"

      #change_table :post_visibilities do |t|
      #  t.rename :post_id, :shareable_id
      #  t.string :shareable_type, :default => 'Post', :null => false
      #end

      sql << "CHANGE COLUMN post_id shareable_id int NOT NULL"
      sql << "ADD shareable_type varchar(60) NOT NULL DEFAULT 'Post'"

      #add_index :share_visibilities, [:shareable_id, :shareable_type, :contact_id], :name => 'shareable_and_contact_id'
      #add_index :share_visibilities, [:shareable_id, :shareable_type, :hidden, :contact_id], :name => 'shareable_and_hidden_and_contact_id'

      sql << "add index `shareable_and_contact_id` (`shareable_id`, `shareable_type`, `contact_id`)"
      sql << "add index `shareable_and_hidden_and_contact_id` (`shareable_id`, `shareable_type`, `hidden`, `contact_id`)"

      execute(start_sql + sql.join(', ') + ';')
    end

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
