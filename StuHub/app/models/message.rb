class Message < ActiveRecord::Base
  validates :user_id, :channel_id, :channel_type, presence: true
  validates :content, length: {minimum: 1}

  def isPost?
    return true if channel_type >= 3
  end
end
