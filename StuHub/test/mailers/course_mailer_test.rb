require 'test_helper'

class CourseMailerTest < ActionMailer::TestCase

  def setup
    @user = users(:michael)
    @course = courses(:courseone)
  end

  test "check joined email" do
    mail = CourseMailer.joined_course(@user, @course)
    assert_equal "[StuHub] Joined Course \"#{@course.course_number}\" (#{@course.department.term.term_name})", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end

  test "check dropped email" do
    mail = CourseMailer.dropped_course(@user, @course)
    assert_equal "[StuHub] Dropped Course \"#{@course.course_number}\" (#{@course.department.term.term_name})", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end

end
