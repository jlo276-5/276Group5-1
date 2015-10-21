require 'test_helper'

class IndexControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
  end

  test "get index page both while logged out or in" do
    get :index
    assert_response :success
    log_in_as(@user)
    get :index
    assert_redirected_to home_path
  end

end
