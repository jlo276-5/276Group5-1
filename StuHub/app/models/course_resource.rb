class CourseResource < Resource
  belongs_to :course

  validates_associated :course

end
