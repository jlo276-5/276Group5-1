class Group < ActiveRecord::Base
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :group_membership_requests, dependent: :destroy

  validates :name, presence: true
  validates :creator, presence: true
end
