class AddCompletedAtToAccountDeletions < ActiveRecord::Migration[4.2]
  def change
    add_column :account_deletions, :completed_at, :datetime
  end
end
