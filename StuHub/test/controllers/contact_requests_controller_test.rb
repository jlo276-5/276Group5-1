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

  test "should redirct destroy if not admin" do
    log_in_as(@user)

    delete :destroy, id: @cr.id
    assert_response :redirect
    assert_redirected_to home_path
    assert_not_empty flash
    assert_not_empty flash[:danger]
  end

  test "should destroy if admin" do
    log_in_as(@admin)

    delete :destroy, id: @cr.id
    assert_response :redirect
    assert_redirected_to contact_requests_path
    assert_not_empty flash
    assert_not_empty flash[:success]
  end

  test "should redirct resolve if not admin" do
    log_in_as(@user)

    post :resolve, id: @cr.id
    assert_response :redirect
    assert_redirected_to home_path
    assert_not_empty flash
    assert_not_empty flash[:danger]
end

  test "should post resolve if admin" do
    log_in_as(@admin)

    post :resolve, id: @cr.id
    assert_response :redirect
    assert_redirected_to contact_requests_path
    assert_not_empty flash
    assert_not_empty flash[:success]
end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create if valid" do
    post :create, contact_request: {title: @cr.title, name: @cr.name, body: @cr.body, email: @cr.email, contact_type: @cr.contact_type}

    assert_response :redirect
    assert_redirected_to help_path
  end

end
