require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  def setup
    @user = users(:lana)
    @superuser = users(:superman)
  end

  test "should redirect index while logged out" do
    get :index
    assert_redirected_to login_path, "Not redirected to login page"
  end

  test "should redirect index while standard logged in" do
    log_in_as(@user)
    get :index
    assert_redirected_to home_path
    get :user_management
    assert_redirected_to home_path
  end

  test "should get index while admin logged in" do
    log_in_as(@superuser)
    get :index
    assert_response :success
  end

  test "should get user_management while admin logged in" do
    log_in_as(@superuser)
    get :user_management
    assert_response :success
  end

end
