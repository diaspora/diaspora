class CreatePreferedlanguages < ActiveRecord::Migration
  def change
    create_table :preferedlanguages do |t|
      t.string :name, :null => false
      t.string :iso_code, :null => false

      t.timestamps
    end
  end
end
