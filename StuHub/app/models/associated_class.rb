class AssociatedClass < ActiveRecord::Base
  belongs_to :course
  has_many :sections, dependent: :destroy

  validates :number, presence: true
  validates :course_id, presence: true
end
