class Department < ActiveRecord::Base
  belongs_to :term
  has_many :courses, dependent: :destroy

  validates :name, presence: true
end
