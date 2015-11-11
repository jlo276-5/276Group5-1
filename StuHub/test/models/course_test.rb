require 'test_helper'

class CourseTest < ActiveSupport::TestCase

  def setup
    @course = courses(:courseone)
  end

  test "should be valid" do
    assert @course.valid?
  end

  test "number should not be blank" do
    @course.number = ""
    assert_not @course.valid?
  end

  test "should have department" do
    @course.department = nil
    assert_not @course.valid?
  end
end
