class AddLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.boolean :positive, :default => true
      t.integer :post_id
      t.integer :author_id
      t.string :guid
      t.text :author_signature
      t.text :parent_author_signature
      t.timestamps
    end
    add_index :likes, :guid, :unique => true
    add_index :likes, :post_id
    add_foreign_key(:likes, :posts, :dependant => :delete)
    add_foreign_key(:likes, :people, :column =>  :author_id, :dependant => :delete)
  end

  def self.down
    drop_table :likes
  end
end
