class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_associated :user
  validates_associated :group

  validates :role, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}

  def newNotifications
    unless self.last_visited_at.nil?
      messages = Message.where(channel_type: 2, channel_id: self.group.id, created_at: (self.last_visited_at..Time.zone.now)).size
      posts = Post.where(channel_type: 2, channel_id: self.group.id, created_at: (self.last_visited_at..Time.zone.now)).size
      return messages+posts
    end
    return 0
  end
end
