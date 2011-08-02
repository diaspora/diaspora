require 'sequel'

db = Sequel.sqlite

db.create_table :cars do
  primary_key :id, :integer, :auto_increment => true
  column :name, :text
  column :notes, :text
end
