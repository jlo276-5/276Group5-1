require 'test_helper'

class IndexControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
  end

  test "get index page both while logged out or in" do
    get :index
    assert_response StuHubSettings.new_landing_page ? :redirect : :success
    log_in_as(@user)
    get :index
    assert_redirected_to home_path
  end

  test "get new_index page both while logged out or in" do
    get :new_index
    assert_response StuHubSettings.new_landing_page ? :success : :redirect
    log_in_as(@user)
    get :new_index
    assert_redirected_to home_path
  end


end
