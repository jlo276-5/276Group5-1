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

  def newNotifications
    unless self.last_visited_at.nil?
      messages = Message.where(channel_type: 1, channel_id: self.course.id, created_at: (self.last_visited_at..Time.zone.now)).size
      posts = Post.where(channel_type: 1, channel_id: self.course.id, created_at: (self.last_visited_at..Time.zone.now)).size
      return messages+posts
    end
    return 0
  end
end
