require 'test_helper'

class GroupsControllerTest < ActionController::TestCase

  def setup
    @admin = users(:superman)
    @user = users(:superwoman)
    @group = groups(:groupone)
    @member = users(:archer)
    @membertwo = users(:mallory)
    @gmr = group_membership_requests(:gmrone)
    @admingm = group_memberships(:gmone)
    @membergm = group_memberships(:gmthree)
  end

  test "should get new" do
    log_in_as(@member)

    get :new
    assert_response :success
    assert_template :new
  end

  test "should get index" do
    log_in_as(@member)

    get :index
    assert_response :success
    assert_template :index
  end

  test "should post search" do
    log_in_as(@member)

    post :search, search: '276'
    assert_response :success
    assert_template :index
  end

  test "should get show" do
    log_in_as(@member)

    get :show, id: @group.id
    assert_response :success
    assert_template :show
  end

  test "should get group_members" do
    log_in_as(@member)

    get :group_members, id: @group.id
    assert_response :success
    assert_template :group_members
  end

  test "should get group_requests" do
    log_in_as(@admin)

    get :group_requests, id: @group.id
    assert_response :success
    assert_template :group_requests
  end

  test "should get edit" do
    log_in_as(@admin)

    get :edit, id: @group.id
    assert_response :success
    assert_template :edit
  end

  test "should redirect group_requests and edit if not admin" do
    log_in_as(@member)

    get :group_requests, id: @group.id
    assert_response :redirect
    assert_redirected_to group_path(@group)
    assert_equal "You are not an admininstrator of this group.", flash[:danger]
    get :edit, id: @group.id
    assert_response :redirect
    assert_redirected_to group_path(@group)
    assert_equal "You are not an admininstrator of this group.", flash[:danger]
  end

  test "should redirect show if not member" do
    log_in_as(@user)

    get :show, id: @group.id
    assert_response :redirect
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "You are not a member of this group yet.", flash[:danger]
  end

  test "should promote demote or kick member if admin" do
    log_in_as(@admin)

    assert_difference '@group.admin_users.size', 1 do
      post :promote_member, id: @group, gm_id: @membergm
    end
    assert_redirected_to users_group_path(@group)
    assert_not flash.empty?
    assert_equal "Promoted #{@member.name} to Administrator in this Group", flash[:success]

    assert_difference '@group.admin_users.size', -1 do
      post :demote_member, id: @group, gm_id: @membergm
    end
    assert_redirected_to users_group_path(@group)
    assert_not flash.empty?
    assert_equal "Demoted #{@member.name} to Member in this Group", flash[:success]

    assert_difference '@group.users.size', -1 do
      post :kick_member, id: @group, gm_id: @membergm
    end
    assert_redirected_to users_group_path(@group)
    assert_not flash.empty?
    assert_equal "Kicked #{@member.name} from this Group", flash[:success]
  end

  test "should not be adminless if last admin demoted" do
    log_in_as(@admin)

    assert_no_difference '@group.admin_users.size' do
      post :demote_member, id: @group, gm_id: @admingm
    end
    assert_redirected_to users_group_path(@group)
    assert_not flash.empty?
    assert_equal "Demoted #{@admin.name} to Member in this Group, set #{@membertwo.name} as new Administrator.", flash[:success]
  end

  test "should redirect member management if not admin" do
    log_in_as(@member)

    assert_no_difference '@group.admin_users.size' do
      post :promote_member, id: @group, gm_id: @membergm
    end
    assert_redirected_to group_path(@group)
    assert_not flash.empty?
    assert_equal "You are not an admininstrator of this group.", flash[:danger]

    assert_no_difference '@group.admin_users.size' do
      post :demote_member, id: @group, gm_id: @membergm
    end
    assert_redirected_to group_path(@group)
    assert_not flash.empty?
    assert_equal "You are not an admininstrator of this group.", flash[:danger]

    assert_no_difference '@group.users.size' do
      post :kick_member, id: @group, gm_id: @membergm
    end
    assert_redirected_to group_path(@group)
    assert_not flash.empty?
    assert_equal "You are not an admininstrator of this group.", flash[:danger]
  end

end
