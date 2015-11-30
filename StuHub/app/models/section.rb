class Section < ActiveRecord::Base
  belongs_to :associated_class
  has_and_belongs_to_many :course_memberships
  has_many :section_times, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :instructors, dependent: :destroy

  validates :key, length: {minimum: 1}
  validates :code, length: {minimum: 1}
  validates :associated_class_id, presence: true

  def course
    self.associated_class.course
  end
end
