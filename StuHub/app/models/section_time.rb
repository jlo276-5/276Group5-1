class SectionTime < ActiveRecord::Base
  belongs_to :section

  validates :section_id, :start_date, :end_date, :start_time, :end_time, :days, presence: true
end
