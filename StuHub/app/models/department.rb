class Department < ActiveRecord::Base
  belongs_to :term
  has_many :courses, dependent: :destroy

  validates :name, length: {minimum: 1}
  validates :term_id, presence: true
end
