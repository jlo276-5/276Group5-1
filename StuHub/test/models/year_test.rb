require 'test_helper'

class YearTest < ActiveSupport::TestCase

  def setup
    @year = years(:fifteen)
  end

  test "should be valid?" do
    assert @year.valid?
  end

  test "number must be present minimum 1" do
    @year.number = ""
    assert_not @year.valid?
  end
end
