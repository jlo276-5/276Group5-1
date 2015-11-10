class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_associated :user
  validates_associated :group

  validates :role, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
end
