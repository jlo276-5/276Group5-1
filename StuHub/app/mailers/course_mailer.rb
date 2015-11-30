class CourseMailer < ApplicationMailer

  def joined_course(user, course)
    @user = user
    @course = course
    mail to: user.email, subject: "[StuHub] Joined Course \"#{course.course_number}\" (#{course.department.term.term_name})"
  end

  def dropped_course(user, course)
    @user = user
    @course = course
    mail to: user.email, subject: "[StuHub] Dropped Course \"#{course.course_number}\" (#{course.department.term.term_name})"
  end

end
