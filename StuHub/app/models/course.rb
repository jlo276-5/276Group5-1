class Course < ActiveRecord::Base
  belongs_to :department
  has_many :associated_classes, dependent: :destroy

  validates :number, presence: true
  validates :department_id, presence: true
end
