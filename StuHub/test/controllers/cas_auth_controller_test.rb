require 'test_helper'

class CasAuthControllerTest < ActionController::TestCase

  def setup
    @institution = institutions(:institution)
  end

  test "should redirect auth for invalid institution id" do
    post :auth, cas_auth: { institution_id: ''}
    assert_response :redirect
    assert_redirected_to login_path
    assert_not flash.empty?
    assert_equal "Invalid Institution ID ", flash[:danger]
  end

  test "should redirect callback for invalid institution id" do
    get :callback, institution_id: '', ticket: ''
    assert_response :redirect
    assert_redirected_to login_path
    assert_not flash.empty?
    assert_equal "Invalid Institution ID ", flash[:danger]
  end

  test "should redirect auth for not supported institution" do
    post :auth, cas_auth: { institution_id: @institution.id }
    assert_response :redirect
    assert_redirected_to login_path
    assert_not flash.empty?
    assert_equal "StuHub does not support CAS authentication for this Institution.", flash[:warning]
  end

  test "should redirect callback for not supported institution" do
    get :callback, institution_id: @institution.id, ticket: ''
    assert_response :redirect
    assert_redirected_to login_path
    assert_not flash.empty?
    assert_equal "StuHub does not support CAS authentication for this Institution.", flash[:warning]
  end

end
