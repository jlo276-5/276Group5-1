require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    @user = users(:superman)
  end

  test "should get login" do
    get :new
    assert_response :success
  end

  test "should redirect login if logged in" do
    log_in_as(@user)

    get :new
    assert_response :redirect
    assert_redirected_to home_url
    assert_equal "You cannot do that while logged in.", flash[:warning]
  end

  test "should redirect create if logged in" do
    log_in_as(@user)

    post :create, session: { email: '', password: '' }
    assert_response :redirect
    assert_redirected_to home_url
    assert_equal "You cannot do that while logged in.", flash[:warning]
  end

  test "should create if valid input" do
    post :create, session: { email: @user.email, password: 'password' }
    assert_response :redirect
    assert_redirected_to home_url
    assert_equal "Successfully logged in.", flash[:success]
  end

  test "should destroy if logged in" do
    log_in_as(@user)

    post :destroy
    assert_redirected_to root_url
    assert_equal "Successfully logged out.", flash[:success]
  end

end
