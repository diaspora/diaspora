class DropTablePostReports < ActiveRecord::Migration
  def up
    drop_table :post_reports
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
