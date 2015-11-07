require 'test_helper'

class AdministrationControllerTest < ActionController::TestCase

  def setup
    @user = users(:lana)
    @superuser = users(:superman)
  end

  test "should redirect main while logged out" do
    get :main
    assert_redirected_to login_path
  end

  test "should redirect main while standard logged in" do
    log_in_as(@user)
    get :main
    assert_redirected_to home_path
  end

  test "should get main while admin logged in" do
    log_in_as(@superuser)
    get :main
    assert_response :success
  end


end
