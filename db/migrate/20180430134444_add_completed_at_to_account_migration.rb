# frozen_string_literal: true

class AddCompletedAtToAccountMigration < ActiveRecord::Migration[5.1]
  def change
    add_column :account_migrations, :completed_at, :datetime, default: nil

    reversible do |change|
      change.up do
        set_completed_at_for_closed_accounts
      end
    end
  end

  def set_completed_at_for_closed_accounts
    # rubocop:disable Rails/SkipsModelValidations
    AccountMigration.joins(:old_person).where(people: {closed_account: true}).update_all(completed_at: Time.zone.now)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
