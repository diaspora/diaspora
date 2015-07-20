class AddRemoveAfterToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :remove_after, :datetime
  end
end
