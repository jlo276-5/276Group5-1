class Course < ActiveRecord::Base
  serialize :enrollment

  belongs_to :department
  has_many :associated_classes, dependent: :destroy
  has_many :course_memberships, dependent: :destroy
  has_many :users, through: :course_memberships

  has_many :course_resources, dependent: :destroy

  validates :number, length: {minimum: 1}
  validates :department_id, presence: true

  def term
    return self.department.term
  end

  def course_number
    "#{self.department.name} #{self.number}"
  end
end
