class Course < ActiveRecord::Base
  belongs_to :department
  has_many :associated_classes, dependent: :destroy
  has_many :course_memberships, dependent: :destroy
  has_many :users, through: :course_memberships

  validates :number, presence: true
  validates :department_id, presence: true
end
