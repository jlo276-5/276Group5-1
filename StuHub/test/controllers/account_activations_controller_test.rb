require 'test_helper'

class AccountActivationsControllerTest < ActionController::TestCase

  def setup
    @user = users(:lana)
  end

  test "should redirect when invalid input" do
    get :edit, id: ''
    assert_redirected_to root_path, "Not redirected to root path"
    assert_not flash.empty?
    assert flash[:danger]
  end

  test "should redirect when already activated" do
    get :edit, id: User.new_token, email: @user.email
    assert_redirected_to root_path, "Not redirected to root page"
    assert_not flash.empty?
    assert flash[:warning]
  end

end
