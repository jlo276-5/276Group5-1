class Message < ActiveRecord::Base
  belongs_to :user
  validates :channel_id, :channel_type, presence: true
  validates :content, length: {minimum: 1, maximum: 256}

  def isPost?
    return true if channel_type >= 3
  end
end
