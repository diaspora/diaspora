class CreatePostReporters < ActiveRecord::Migration
  def change
    create_table :post_reporters do |t|
      t.integer :post_id
      t.string :user_id
      t.boolean :reviewed, :default => 0
      t.text :text

      t.timestamps
    end
  end
end
