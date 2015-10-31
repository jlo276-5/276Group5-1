class Term < ActiveRecord::Base
  belongs_to :year
  has_many :departments, dependent: :destroy
end
