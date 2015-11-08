class Message < ActiveRecord::Base
  validates :user_id, :channel_id, :channel_type, presence: true
  validates :content, length: {minimum: 1}
end
