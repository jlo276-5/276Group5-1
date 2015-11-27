class Post < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :channel_id, :channel_type, presence: true
  validates :body, length: {minimum: 10}
end
