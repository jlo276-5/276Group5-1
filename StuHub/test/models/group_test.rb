require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  def setup
    @group = groups(:groupone)
  end

  test "should be valid" do
    assert @group.valid?
  end

  test "name is required" do
    @group.name = ""
    assert_not @group.valid?
  end

  test "creator is required" do
    @group.creator = ""
    assert_not @group.valid?
  end

  test "should have admins" do
    assert_equal 1, @group.admin_users.size
  end

end
