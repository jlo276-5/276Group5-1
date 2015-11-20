class AssociatedClass < ActiveRecord::Base
  belongs_to :course
  has_many :sections, dependent: :destroy

  validates :number, numericality: {greater_than_or_equal_to: 0}
  validates :course_id, presence: true
end
