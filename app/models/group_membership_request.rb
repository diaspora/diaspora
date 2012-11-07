class GroupMembershipRequest < ActiveRecord::Base
  belongs_to :group
  belongs_to :person

  validates :group_id, :presence => true
  validates :person_id, :presence => true
end
