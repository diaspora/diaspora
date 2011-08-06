class DropExtraColumns < ActiveRecord::Migration
  def self.up
    remove_column :services, :provider
    remove_column :statistics, :type
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
