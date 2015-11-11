require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase

  def setup
    @dept = departments(:cmpt)
  end

  test "should be valid" do
    assert @dept.valid?
  end

  test "name must not be blank" do
    @dept.name = ""
    assert_not @dept.valid?
  end

  test "term must be present" do
    @dept.term = nil
    assert_not @dept.valid?
  end
end
