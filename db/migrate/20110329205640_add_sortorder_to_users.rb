class AddSortorderToUsers < ActiveRecord::Migration
  def self.up
    add_column(:users, :sort_order, :string, :default => "updated_at")
  end

  def self.down
    remove_column(:users, :sort_order)
  end
end
