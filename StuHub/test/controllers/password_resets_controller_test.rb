require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:superman)
  end

  test "should get new when not logged in" do
    get :new
    assert_response :success
  end

  test "should redirect new when logged in" do
    log_in_as(@user)

    get :new
    assert_response :redirect
    assert_redirected_to user_path(@user)
  end

  test "should create and send if valid user" do
    post :create, password_reset: { email: "derp@derpity.com" }
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_redirected_to root_url
    assert_not flash.empty?
    assert_equal "If an account with the specified email address exists, an email has been sent with password reset instructions.", flash[:info]

    post :create, password_reset: { email: "superman@example.ca" }
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to root_url
    assert_not flash.empty?
    assert_equal "If an account with the specified email address exists, an email has been sent with password reset instructions.", flash[:info]
  end

end
