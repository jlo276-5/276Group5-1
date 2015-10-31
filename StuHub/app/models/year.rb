class Year < ActiveRecord::Base
  has_many :terms, dependent: :destroy
end
