class AddIndexesToSerivces < ActiveRecord::Migration
  def self.up
    change_column(:services, :type, :string, :limit => 127)
    change_column(:services, :uid, :string, :limit => 127)
    add_index :services, [:type, :uid]
  end

  def self.down
    remove_index :services, :column => [:type, :uid]
  end
end
