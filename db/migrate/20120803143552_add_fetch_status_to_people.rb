class AddFetchStatusToPeople < ActiveRecord::Migration
  def change
    add_column :people, :fetch_status, :integer, :default => 0
  end
end
