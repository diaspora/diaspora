class RenamePersonToAuthor < ActiveRecord::Migration
  def self.up
    remove_foreign_key(:comments, :people)
    remove_foreign_key(:posts, :people)
    rename_column :comments, :person_id, :author_id
    rename_column :posts, :person_id, :author_id
    add_foreign_key(:comments, :people, :column => :author_id, :dependent => :delete)
    add_foreign_key(:posts, :people, :column => :author_id, :dependent => :delete)
  end

  def self.down
    remove_foreign_key(:comments, :people, :column => :author_id)
    remove_foreign_key(:posts, :people, :column => :author_id)
    rename_column :comments, :author_id, :person_id
    rename_column :posts, :author_id, :person_id
    add_foreign_key(:comments, :people, :dependent => :delete)
    add_foreign_key(:posts, :people, :dependent => :delete)
  end
end
