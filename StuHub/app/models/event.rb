class Event < ActiveRecord::Base
  cattr_accessor :weekdays

  @@weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

  belongs_to :user
  validates :title, :start_time, :end_time, :start_date, :end_date, presence: true
  validate :start_before_end
  validate :recurrance_start_before_end, if: "dow != []"

  def start_before_end
    errors.add(:end_time, "can't come before or be the same as start time") if self.end_time<=self.start_time
  end
  def recurrance_start_before_end
    errors.add(:end_date, "can't come before or be the same as start date") if self.end_date<=self.start_date
  end

end
