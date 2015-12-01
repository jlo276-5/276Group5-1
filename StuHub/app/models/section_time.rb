class SectionTime < ActiveRecord::Base
  belongs_to :section

  @@weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

  validates :section_id, :start_date, :end_date, :start_time, :end_time, :days, presence: true

  def day_array
    arr = []
    days.split(", ").each do |day|
      unless (i = @@weekdays.index(day)).nil?
        arr << i
      end
    end
    return arr
  end
end
