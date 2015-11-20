class Term < ActiveRecord::Base
  belongs_to :year
  has_many :departments, dependent: :destroy

  validates :name, length: {minimum: 1}
  validates :year_id, presence: true
end
