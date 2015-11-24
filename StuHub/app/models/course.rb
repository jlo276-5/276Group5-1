class Course < ActiveRecord::Base
  serialize :enrollment
  
  belongs_to :department
  has_many :associated_classes, dependent: :destroy
  has_many :course_memberships, dependent: :destroy
  has_many :users, through: :course_memberships

  validates :number, length: {minimum: 1}
  validates :department_id, presence: true
end
