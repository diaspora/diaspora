class CreateNoteExtensions < ActiveRecord::Migration
  def self.up
    create_table :note_extensions do |t|
      t.text :text, :limit => 64.kilobytes + 1
      t.integer :post_id

      t.timestamps
    end
  end

  def self.down
    drop_table :note_extensions
  end
end
