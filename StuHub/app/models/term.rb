class Term < ActiveRecord::Base
  belongs_to :institution
  has_many :departments, dependent: :destroy
  has_many :courses, through: :departments

  validates :name, length: {minimum: 1}
  validates :year, numericality: {integer_only: true, minimum: 1900, maximum: 2100}
  validates :term_reference, length: {minimum: 1}
  validates :institution_id, :enrollment_start_date, :start_date, :end_date, :exams_end_date, presence: true
  validates :data_url, length: {minimum: 11}, if: "data_mode == 1"

  def term_name
    return "#{name} #{year}"
  end

  def term_name_long
    return "#{name} #{year} (#{term_reference})"
  end
end
