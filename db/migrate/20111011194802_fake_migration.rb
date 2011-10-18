class FakeMigration < ActiveRecord::Migration
  def self.up
    remove_foreign_key :aspect_visibilities, :posts
    remove_foreign_key :post_visibilities, :posts
  end

  def self.down
  end
end
