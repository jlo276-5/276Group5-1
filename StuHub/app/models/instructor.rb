class Instructor < ActiveRecord::Base
  belongs_to :section

  validates :first_name, :last_name, :section_id, presence: true
end
