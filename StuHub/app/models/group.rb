class Group < ActiveRecord::Base
  belongs_to :institution
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :group_membership_requests, dependent: :destroy

  has_many :group_resources, dependent: :destroy

  validates :name, presence: true
  validates :creator, presence: true

  def admin_users
    self.group_memberships.where(role: 1)
  end
end
