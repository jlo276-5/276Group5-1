class Resource < ActiveRecord::Base
  belongs_to :user
  validates :name, :description, :file_name, :content_type, presence: true

end
