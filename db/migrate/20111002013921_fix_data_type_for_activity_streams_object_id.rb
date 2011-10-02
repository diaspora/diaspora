class FixDataTypeForActivityStreamsObjectId < ActiveRecord::Migration
  def self.up
    change_table :posts do |t|
      t.change :objectId, :string
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
