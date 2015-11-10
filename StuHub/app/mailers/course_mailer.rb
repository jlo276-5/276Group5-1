class CourseMailer < ApplicationMailer

  def joined_course(user, course)
    @user = user
    @course = course
    mail to: user.email, subject: "[StuHub] Added Course #{course.department.name} #{course.name}"
  end

  def dropped_course(user, course)
    @user = user
    @course = course
    mail to: user.email, subject: "[StuHub] Dropped Course #{course.department.name} #{course.name}"
  end

end
