class FixWrongOnlySharing < ActiveRecord::Migration
  def up
    Contact.where(sharing: true, receiving: false)
      .where(id: AspectMembership.select(:contact_id))
      .update_all(receiving: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
