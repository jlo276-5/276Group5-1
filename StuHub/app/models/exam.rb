class Exam < ActiveRecord::Base
  belongs_to :course

  validates :exam_start, :exam_end, presence: true
  validates :section_id, presence: true
end
