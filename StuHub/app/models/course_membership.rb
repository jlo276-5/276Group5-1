class CourseMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_and_belongs_to_many :sections

  validates_associated :user
  validates_associated :course

  validates :course_id, uniqueness: { scope: :user_id }

  def sectionInMembership?(s_id)
    return !self.sections.find_by(id: s_id).nil?
  end

end
