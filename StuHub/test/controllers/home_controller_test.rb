require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
  end

  test "get home page both while logged in or not" do
    get :home
    assert_redirected_to login_path
    assert_equal "Please log in.", flash[:danger]
    log_in_as(@user)
    get :home
    assert_response :success
  end

end
