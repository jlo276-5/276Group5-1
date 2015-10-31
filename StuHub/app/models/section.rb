class Section < ActiveRecord::Base
  belongs_to :associated_class
  has_many :section_times, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :instructors, dependent: :destroy
end
