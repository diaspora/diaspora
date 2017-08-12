class DeviseAddLastseenableUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :last_seen, :datetime
    User.find_each do |user|
      user.update_column(:last_seen, user.last_sign_in_at)
    end
  end
  
  def self.down
    remove_column :users, :last_seen
  end
end