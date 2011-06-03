class LikesDependentDelete < ActiveRecord::Migration
  def self.up
    remove_foreign_key :likes, :column => :author_id
    remove_foreign_key :likes, :post
    add_foreign_key(:likes, :posts, :dependent => :delete)
    add_foreign_key(:likes, :people, :column =>  :author_id, :dependent => :delete)
  end

  def self.down
    remove_foreign_key(:likes, :posts)
    remove_foreign_key(:likes, :people, :column =>  :author_id)
    add_foreign_key :likes, :people, :column => :author_id
    add_foreign_key :likes, :post
  end
end
