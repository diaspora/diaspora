class AddOrderIdToAspects < ActiveRecord::Migration
  def self.up
    add_column :aspects, :order_id, :integer
  end

  def self.down
    remove_column :aspects, :order_id
  end
end
