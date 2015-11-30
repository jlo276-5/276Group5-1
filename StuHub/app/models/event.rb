class Event < ActiveRecord::Base
    belongs_to :user
    validates :title, presence: true
    validate :start_before_end

    def start_before_end
      errors.add(:end_time, "can't come before start time") if
        self.end_time<self.start_time
    end

end
