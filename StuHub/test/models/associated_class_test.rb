require 'test_helper'

class AssociatedClassTest < ActiveSupport::TestCase

  def setup
    @ac = associated_classes(:cmptone)
  end

  test "should be valid" do
    assert @ac.valid?
  end

  test "number should be present" do
    @ac.number = nil
    assert_not @ac.valid?
  end

  test "course should be present" do
    @ac.course = nil
    assert_not @ac.valid?
  end
end
