require 'test_helper'

class ContactRequestsControllerTest < ActionController::TestCase

  def setup
    @admin = users(:archer)
    @cr = contact_requests(:one)
    @user = users(:lana)
  end

  test "should redirect index if not logged in" do
    get :index
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "should redirct index if not admin" do
    log_in_as(@user)

    get :index
    assert_response :redirect
    assert_redirected_to home_path
  end

  test "should get index if admin" do
    log_in_as(@admin)

    get :index
    assert_response :success
  end

  test "should redirect show if not logged in" do
    get :show, id: @cr.id
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "should redirct show if not admin" do
    log_in_as(@user)

    get :show, id: @cr.id
    assert_response :redirect
    assert_redirected_to home_path
  end

  test "should get show if admin" do
    log_in_as(@admin)

    get :show, id: @cr.id
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end
