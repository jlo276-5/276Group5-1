require 'test_helper'

class InstitutionsControllerTest < ActionController::TestCase

  def setup
    @user = users(:lana)
    @adminuser = users(:michael)
    @superuser = users(:superman)
    @institution = institutions(:institution)
  end

  test "should redirect regular users but allow show" do
    log_in_as(@user)
    get :new
    assert_redirected_to home_path
    get :show, id: @institution
    assert_response :success
    get :index
    assert_redirected_to home_path
  end

  test "should redirect get new if admin" do
    log_in_as(@adminuser)
    get :new
    assert_redirected_to home_path
  end

  test "should get new if super" do
    log_in_as(@superuser)
    get :new
    assert_response :success
  end

  test "should redirect edits if not super" do
    log_in_as(@adminuser)
    get :edit, id: @institution.id
    assert_response :redirect
    patch :update, id: @institution, institution: { name: @institution.name }
    assert_not flash.empty?
    assert_redirected_to home_path
  end

  test "should allow edits if super" do
    log_in_as(@superuser)
    get :edit, id: @institution.id
    assert_response :success
    patch :update, id: @institution, institution: { name: @institution.name }
    assert_not flash.empty?
    assert flash[:success]
    assert_redirected_to institutions_path
  end

end
