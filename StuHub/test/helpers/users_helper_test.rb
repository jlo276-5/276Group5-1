require 'test_helper'

class UsersHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
  end

  test "should always return an avatar image tag" do
    image = avatar_for(@user)
    @user.avatar_url = "http://i.stack.imgur.com/tKsDb.png"
    image = avatar_for(@user)
  end
end
