require 'test_helper'

class SectionTest < ActiveSupport::TestCase

  def setup
    @section = sections(:cmptoneone)
  end

  test "should be valid" do
    assert @section.valid?
  end

  test "should have a key" do
    @section.key = ""
    assert_not @section.valid?
  end

  test "should have a code" do
    @section.code = ""
    assert_not @section.valid?
  end

  test "should have an associated_class" do
    @section.associated_class = nil
    assert_not @section.valid?
  end

  test "should have a course" do
    assert_equal courses(:courseone), @section.course 
  end
end
