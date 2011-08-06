class AddMoreIndicies < ActiveRecord::Migration
  def self.up
    #For making validates_uniqueness_of, :case_sensitive => false, fast
    add_index :users, [:id, :username], :unique => true
    add_index :users, [:id, :email]
    add_index :people, [:id, :diaspora_handle], :unique => true

    #For the includes of photos in the stream
    add_index :posts, [:id, :type]
  end

  def self.down
    remove_index :users, [:id, :username]
    remove_index :users, [:id, :email]
    remove_index :people, [:id, :diaspora_handle]

    remove_index :posts, [:id, :type]
  end
end
