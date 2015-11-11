require 'test_helper'

class TermTest < ActiveSupport::TestCase

  def setup
    @term = terms(:fifteenfall)
  end

  test "should be valid" do
    assert @term.valid?
  end

  test "name should be not be blank" do
    @term.name = ""
    assert_not @term.valid?
  end

  test "year should be present" do
    @term.year = nil
    assert_not @term.valid?
  end
end
