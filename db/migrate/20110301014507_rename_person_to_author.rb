class RenamePersonToAuthor < ActiveRecord::Migration
  def self.up
    remove_foreign_key(:comments, :people)
    rename_column :comments, :person_id, :author_id
    add_foreign_key(:comments, :people, :column => :author_id, :dependent => :delete)
  end

  def self.down
    remove_foreign_key(:comments, :people, :column => :author_id)
    rename_column :comments, :author_id, :person_id
    add_foreign_key(:comments, :people, :dependent => :delete)
  end
end
