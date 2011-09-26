class FixIndexesToSerivces < ActiveRecord::Migration
  # This alters the tables to avoid a mysql bug
  # See http://bugs.joindiaspora.com/issues/835
  def self.up
    remove_index :services, :column => [:type, :uid]
    change_column(:services, :type, :string, :limit => 127)
    change_column(:services, :uid, :string, :limit => 127)
    add_index :services, [:type, :uid]
  end

  def self.down
    remove_index :services, :column => [:type, :uid]
  end
end
