# frozen_string_literal: true

class RemoveServices < ActiveRecord::Migration[6.1]
  def up
    change_table :posts, bulk: true do |t|
      t.remove :tweet_id, :tumblr_ids
    end

    drop_table :services
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Removing services is irreversible"
  end
end
