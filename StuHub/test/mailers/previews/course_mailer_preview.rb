# Preview all emails at http://localhost:3000/rails/mailers/course_mailer
class CourseMailerPreview < ActionMailer::Preview

  def joined_course
    user = User.first
    course = Course.first
    CourseMailer.joined_course(user, course)
  end

  def dropped_course
    user = User.first
    course = Course.first
    CourseMailer.dropped_course(user, course)
  end

end
