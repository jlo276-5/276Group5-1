require 'test_helper'

class SectionTest < ActiveSupport::TestCase

  def setup
    @section = sections(:cmptoneone)
  end

  test "should be valid" do
    assert @section.valid?
  end

  test "should have a unique number" do
    @section.unique_number = ""
    assert_not @section.valid?
  end

  test "should have a key" do
    @section.key = ""
    assert_not @section.valid?
  end

  test "should have a code" do
    @section.code = ""
    assert_not @section.valid?
  end
end
