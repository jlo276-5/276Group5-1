class GroupMembershipRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_associated :user
  validates_associated :group
end
