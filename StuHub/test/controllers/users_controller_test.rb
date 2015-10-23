require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @super_user = users(:superman)
    @other_super_user = users(:superwoman)
    @admin_user = users(:michael)
    @other_admin_user = users(:archer)
    @user = users(:lana)
    @other_user = users(:mallory)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when standard updates any other" do
    log_in_as(@user)

    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to user_url(@user)
    assert_not flash.empty?
    assert flash[:success]
    flash.clear

    patch :update, id: @other_user, user: { name: @other_user.name, email: @other_user.email }
    assert_redirected_to users_url
    assert_not flash.empty?
    assert flash[:danger]
    flash.clear

    patch :update, id: @admin_user, user: { name: @admin_user.name, email: @admin_user.email }
    assert_redirected_to users_url
    assert_not flash.empty?
    assert flash[:danger]
    flash.clear

    patch :update, id: @super_user, user: { name: @super_user.name, email: @super_user.email }
    assert_redirected_to users_url
    assert_not flash.empty?
    assert flash[:danger]
    flash.clear
  end

  test "should redirect update when admin tries to update other admin or super" do
    log_in_as(@admin_user)

    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to user_url(@user)
    assert_not flash.empty?
    assert flash[:success]
    flash.clear

    patch :update, id: @admin_user, user: { name: @admin_user.name, email: @admin_user.email }
    assert_redirected_to user_url(@admin_user)
    assert_not flash.empty?
    assert flash[:success]
    flash.clear

    patch :update, id: @other_admin_user, user: { name: @other_admin_user.name, email: @other_admin_user.email }
    assert_redirected_to user_url(@other_admin_user)
    assert_not flash.empty?
    assert flash[:danger]
    flash.clear

    patch :update, id: @super_user, user: { name: @super_user.name, email: @super_user.email }
    assert_redirected_to user_url(@super_user)
    assert_not flash.empty?
    assert flash[:danger]
    flash.clear
  end

  test "should redirect update when super tries to update other super" do
    log_in_as(@super_user)

    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to user_url(@user)
    assert_not flash.empty?
    assert flash[:success]
    flash.clear

    patch :update, id: @admin_user, user: { name: @admin_user.name, email: @admin_user.email }
    assert_redirected_to user_url(@admin_user)
    assert_not flash.empty?
    assert flash[:success]
    flash.clear

    patch :update, id: @super_user, user: { name: @super_user.name, email: @super_user.email }
    assert_redirected_to user_url(@super_user)
    assert_not flash.empty?
    assert flash[:success]
    flash.clear

    patch :update, id: @other_super_user, user: { name: @other_super_user.name, email: @other_super_user.email }
    assert_redirected_to user_url(@other_super_user)
    assert_not flash.empty?
    assert flash[:danger]
    flash.clear
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @admin_user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when standard" do
    log_in_as(@user)

    assert_no_difference 'User.count' do
      delete :destroy, id: @other_user
    end
    assert_redirected_to users_url

    assert_no_difference 'User.count' do
      delete :destroy, id: @admin_user
    end
    assert_redirected_to users_url

    assert_no_difference 'User.count' do
      delete :destroy, id: @super_user
    end
    assert_redirected_to users_url
  end

  test "should redirect destroy when admin tries to destroy admin or super" do
    log_in_as(@admin_user)

    assert_difference 'User.count', -1 do
      delete :destroy, id: @other_user
    end
    assert_redirected_to users_url

    assert_no_difference 'User.count' do
      delete :destroy, id: @admin_user
    end
    assert_redirected_to user_url(@admin_user)

    assert_no_difference 'User.count' do
      delete :destroy, id: @super_user
    end
    assert_redirected_to user_url(@super_user)
  end

  test "should redirect when super tries to destroy super" do
    log_in_as(@super_user)

    assert_difference 'User.count', -1 do
      delete :destroy, id: @other_user
    end
    assert_redirected_to users_url

    assert_difference 'User.count', -1 do
      delete :destroy, id: @admin_user
    end
    assert_redirected_to users_url

    assert_no_difference 'User.count' do
      delete :destroy, id: @super_user
    end
    assert_redirected_to user_url(@super_user)
  end
end
