class FixWrongOnlySharing < ActiveRecord::Migration[4.2]
  def up
    Contact.where(sharing: true, receiving: false)
      .where(id: AspectMembership.select(:contact_id))
      .update_all(receiving: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
