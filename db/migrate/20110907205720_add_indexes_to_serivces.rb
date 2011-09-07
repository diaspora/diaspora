class AddIndexesToSerivces < ActiveRecord::Migration
  def self.up
    add_index :services, [:type, :uid]
  end

  def self.down
    remove_index :services, :column => [:type, :uid]
  end
end
