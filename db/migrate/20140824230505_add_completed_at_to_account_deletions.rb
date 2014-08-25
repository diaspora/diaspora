class AddCompletedAtToAccountDeletions < ActiveRecord::Migration
  def change
    add_column :account_deletions, :completed_at, :datetime
  end
end
