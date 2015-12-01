require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  def setup
    @admin = users(:superman)
    @group = groups(:groupone)
    @unlimitgroup = groups(:grouptwo)
    @member = users(:archer)
    @membertwo = users(:mallory)
    @user = users(:lana)
    @gm = group_memberships(:gmthree)
  end

  test "should redirect create if invalid group" do
    log_in_as(@user)

    post :create, user_id: @user.id, group_id: 'vyu7'
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "No Group exists with id vyu7", flash[:danger]
  end

  test "should redirect create if already member" do
    log_in_as(@member)

    post :create, group_id: @group.id, user_id: @member.id
    assert_redirected_to group_path(@group)
    assert_not flash.empty?
    assert_equal "You are already a member of this group.", flash[:warning]
  end

  test "should redirect create if need join approval" do
    log_in_as(@user)

    post :create, group_id: @group.id, user_id: @user.id
    assert_redirected_to new_gm_request_path(group_id: @group.id, user_id: @user.id)
    assert_not flash.empty?
    assert_equal "This Group requires Join Approvals.", flash[:info]
  end

  test "should allow create if all valid" do
    log_in_as(@user)

    assert_difference '@unlimitgroup.users.size', 1 do
      post :create, group_id: @unlimitgroup.id, user_id: @user.id
    end
    assert_redirected_to group_path(@unlimitgroup)
    assert_not flash.empty?
    assert_equal "Joined Group #{@unlimitgroup.name}", flash[:success]
  end

  test "should redirect destroy if invalid group membership" do
    log_in_as(@user)

    post :destroy, id: 'vyr37'
    assert_response :redirect
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "No such Group Membership Exists", flash[:danger]
  end

  test "should redirect destroy if not group administrator" do
    log_in_as(@membertwo)

    post :destroy, id: group_memberships(:gmthree).id
    assert_response :redirect
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "You do not have the permission to do that.", flash[:danger]
  end

  test "should redirect destroy if not correct user" do
    log_in_as(@member)

    post :destroy, id: group_memberships(:gmfive).id
    assert_response :redirect
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "You do not have the permission to do that.", flash[:danger]
  end

  test "should destroy if valid membership and member" do
    log_in_as(@member)

    assert_difference '@group.users.size', -1 do
      post :destroy, id: @gm.id
    end
    assert_response :redirect
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "Left Group #{group_memberships(:gmthree).group.name}", flash[:success]
  end

  test "should destroy group if no more members" do
    log_in_as(@admin)

    assert_difference '@group.users.size', -2 do
      post :destroy, id: group_memberships(:gmthree).id
      post :destroy, id: group_memberships(:gmfive).id
    end
    assert_redirected_to groups_path
    assert_difference '@group.users.size', -1 do
      post :destroy, id: group_memberships(:gmone).id
    end
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "The Group #{@group.name} was deleted because there were no more members left.", flash[:info]
end

  test "should promote next user if last admin leaves" do
    log_in_as(@admin)

    assert_difference '@group.users.size', -1 do
      post :destroy, id: group_memberships(:gmone).id
    end
    assert_redirected_to groups_path
    assert_not flash.empty?
    assert_equal "Left Group #{@group.name}, set #{@membertwo.name} as new Administrator.", flash[:success]
    assert @membertwo.adminOfGroup?(@group)
  end
end
