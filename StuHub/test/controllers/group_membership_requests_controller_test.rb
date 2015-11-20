require 'test_helper'

class GroupMembershipRequestsControllerTest < ActionController::TestCase

    def setup
      @user = users(:archer)
      @user2 = users(:michael)
      @user3 = users(:lana)
      @superuser = users(:superman)
      @g1 = groups(:groupone)
      @g2 = groups(:grouptwo)
      @gmr1 = group_membership_requests(:gmrone)
      @gmr2 = group_membership_requests(:gmrtwo)
    end

    test "should redirect new if invalid group" do
      log_in_as(@user)

      get :new, group_id: ''
      assert_response :redirect
      assert_redirected_to groups_path
      assert flash[:danger]
    end

    test "should redirect new to groups if not limited" do
      log_in_as(@user)

      get :new, group_id: @g2.id
      assert_redirected_to groups_path
      assert_not flash.empty?
      assert flash[:warning]
    end

    test "should create on valid request" do
      log_in_as(@user)

      get :new, group_id: @g1.id
      assert_template :new
      assert_difference '@g1.group_membership_requests.size', 1 do
        post :create, group_membership_request: { group_id: @g1.id, request_message: "" }
      end
      assert_redirected_to groups_path
      assert_not flash.empty?
      assert flash[:success]
    end

    test "should redirect approve or reject if not member" do
      log_in_as(@user2)

      assert_no_difference '@g1.group_membership_requests.size' do
        post :approve, id: @gmr1.id
      end
      assert_redirected_to @gmr1.group
      assert flash[:danger]
    end

    test "should redirect approve or reject if not admin" do
      log_in_as(@user)

      assert_no_difference '@g1.group_membership_requests.size' do
        post :approve, id: @gmr1.id
      end
      assert_redirected_to @gmr1.group
      assert flash[:danger]
    end

    test "should allow approve or reject if admin" do
      log_in_as(@superuser)

      assert_difference '@g1.group_membership_requests.size', -2 do
        post :approve, id: @gmr1.id
        assert_redirected_to requests_group_path(@gmr1.group)
        post :reject, id: @gmr2.id
        assert_redirected_to requests_group_path(@gmr2.group)
      end
      assert flash[:success]
    end

end
