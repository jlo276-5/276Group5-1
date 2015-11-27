class Resource < ActiveRecord::Base
  belongs_to :group
  belongs_to :course
  validate :either_group_or_course

  private

  def either_group_or_course
    unless group_id.blank? ^ course_id.blank?
      errors.add(:base, "Resource must belong to either a Course or a Group, not both.")
    end
  end
end
