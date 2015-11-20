class Year < ActiveRecord::Base
  has_many :terms, dependent: :destroy

  validates :number, length: {minimum: 1}
end
