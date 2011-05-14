class UpdateDeviseInvitable < ActiveRecord::Migration
  def self.up
    add_column(:users, :invitation_limit, :integer)
    add_column(:users, :invited_by_id, :integer)
    add_column(:users, :invited_by_type, :string)
  end

  def self.down
    remove_column(:users, :invited_by_type)
    remove_column(:users, :invited_by_id)
    remove_column(:users, :invitation_limit)
  end
end
