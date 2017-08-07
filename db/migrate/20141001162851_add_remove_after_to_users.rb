class AddRemoveAfterToUsers < ActiveRecord::Migration[4.2]
  def change
  	add_column :users, :remove_after, :datetime
  end
end
