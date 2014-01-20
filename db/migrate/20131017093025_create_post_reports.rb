class CreatePostReports < ActiveRecord::Migration
  def change
    create_table :post_reports do |t|
      t.integer :post_id, :null => false
      t.string :user_id
      t.boolean :reviewed, :default => false
      t.text :text

      t.timestamps
    end
    add_index :post_reports, :post_id
  end
end
