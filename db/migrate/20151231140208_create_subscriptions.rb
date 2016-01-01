class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscriber_id
      t.integer :channel_id
      t.string :channel_type

      t.timestamps null: false
    end
  end
end
